import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface Appointment {
  id: string;
  user_id: string;
  pet_name: string;
  preferred_date: string;
  preferred_time: string;
  status: string;
}

interface User {
  id: string;
  full_name: string;
  email: string;
}

interface MessageTracking {
  id: string;
  appointment_id: string;
  message_type: string;
  message_content: string;
  created_at: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const now = new Date()
    console.log(`Auto message sender running at ${now.toISOString()}`)

    // Get all pending appointments
    const { data: appointments, error: appointmentsError } = await supabase
      .from('grooming_appointments')
      .select('id, user_id, pet_name, preferred_date, preferred_time, status')
      .eq('status', 'Pending')

    if (appointmentsError) {
      console.error('Error fetching appointments:', appointmentsError)
      return new Response(JSON.stringify({ error: 'Failed to fetch appointments' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (!appointments || appointments.length === 0) {
      console.log('No pending appointments found')
      return new Response(JSON.stringify({ message: 'No pending appointments found' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    let apologiesSent = 0

    for (const appointment of appointments) {
      const appointmentDate = new Date(appointment.preferred_date)
      const timeParts = appointment.preferred_time.split(':')
      const appointmentHour = parseInt(timeParts[0])
      const appointmentMinute = parseInt(timeParts[1])
      
      const appointmentDateTime = new Date(
        appointmentDate.getFullYear(),
        appointmentDate.getMonth(),
        appointmentDate.getDate(),
        appointmentHour,
        appointmentMinute
      )

      // Get user details
      const { data: user, error: userError } = await supabase
        .from('users')
        .select('id, full_name, email')
        .eq('id', appointment.user_id)
        .single()

      if (userError) {
        console.error(`Error fetching user ${appointment.user_id}:`, userError)
        continue
      }

             // Reminder messages are now handled by client-side (user system)
       // Server only handles apology messages when appointments pass their time

      // Check if apology should be sent (appointment time has passed)
      if (now > appointmentDateTime) {
        // Check if apology already sent
        const { data: existingApology } = await supabase
          .from('message_tracking')
          .select('id')
          .eq('appointment_id', appointment.id)
          .eq('message_type', 'apology')
          .maybeSingle()

        if (!existingApology) {
          const apologyMessage = `We're sorry! Your grooming appointment status was not updated before the scheduled time. We sincerely apologize for the inconvenience this may have caused. Please feel free to reach out to us or rebook your appointment at your convenience. Thank you for your understanding!`

          // Send apology message
          await supabase.from('admin_messages').insert({
            user_id: appointment.user_id,
            appointment_id: appointment.id,
            message: apologyMessage,
            is_from_admin: true,
            is_read: false,
          })

          await supabase.from('user_messages').insert({
            user_id: appointment.user_id,
            appointment_id: appointment.id,
            message: apologyMessage,
            is_from_admin: true,
            is_read: false,
          })

          // Update appointment status to Cancelled
          await supabase
            .from('grooming_appointments')
            .update({ status: 'Cancelled' })
            .eq('id', appointment.id)

          // Record apology sent
          await supabase.from('message_tracking').insert({
            appointment_id: appointment.id,
            message_type: 'apology',
            message_content: apologyMessage,
          })

          apologiesSent++
          console.log(`Sent apology for appointment ${appointment.id}`)
        }
      }
    }

    const result = {
      message: 'Auto message sender completed',
      apologiesSent,
      totalAppointments: appointments.length,
      timestamp: now.toISOString()
    }

    console.log('Auto message sender result:', result)

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error in auto message sender:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
}) 
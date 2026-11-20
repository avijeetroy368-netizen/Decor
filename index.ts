// NOORÉ secure order-creation starter for Supabase Edge Functions.
// Deploy only after applying the accompanying SQL migration and setting secrets.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}
Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  try {
    const body = await req.json()
    const required = ['customer_name', 'phone', 'shipping_address', 'items']
    for (const key of required) if (!body?.[key]) return Response.json({ error: `Missing ${key}` }, { status: 400, headers: corsHeaders })
    if (!Array.isArray(body.items) || body.items.length < 1 || body.items.length > 30) return Response.json({ error: 'Invalid items list' }, { status: 400, headers: corsHeaders })
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } })
    const { data, error } = await supabase.rpc('noore_create_order', {
      p_customer_name: String(body.customer_name).slice(0, 120),
      p_email: body.email ? String(body.email).slice(0, 254) : null,
      p_phone: String(body.phone).slice(0, 30),
      p_shipping_address: body.shipping_address,
      p_items: body.items,
    })
    if (error) throw error
    return Response.json({ ok: true, order: data }, { headers: corsHeaders })
  } catch (err) {
    console.error('create-order error', err)
    return Response.json({ error: 'Unable to create order. Please try again.' }, { status: 500, headers: corsHeaders })
  }
})

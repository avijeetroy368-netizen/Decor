-- Apply after supabase_schema.sql. This RPC is intended to be called ONLY by the
-- create-order Edge Function using the service-role key. Never expose that key.
create or replace function public.noore_create_order(
  p_customer_name text,
  p_email text,
  p_phone text,
  p_shipping_address jsonb,
  p_items jsonb
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order_id uuid;
  v_order_number text;
  v_items jsonb;
  v_subtotal integer := 0;
  v_total integer := 0;
  v_shipping integer := 0;
  v_item jsonb;
  v_product_id uuid;
  v_qty integer;
  v_product record;
  v_order_item jsonb;
begin
  if length(trim(coalesce(p_customer_name,''))) < 2 or length(trim(coalesce(p_phone,''))) < 6 then
    raise exception 'Invalid customer details';
  end if;
  if jsonb_typeof(p_shipping_address) <> 'object' or jsonb_typeof(p_items) <> 'array' then
    raise exception 'Invalid address or items';
  end if;
  if jsonb_array_length(p_items) < 1 or jsonb_array_length(p_items) > 30 then
    raise exception 'Invalid item count';
  end if;
  v_items := '[]'::jsonb;
  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty := (v_item->>'quantity')::integer;
    if v_qty < 1 or v_qty > 10 then raise exception 'Invalid quantity'; end if;
    select id, name, price_inr, stock, is_published into v_product
      from products where id = v_product_id for update;
    if not found or not v_product.is_published then raise exception 'Product unavailable'; end if;
    if v_product.stock < v_qty then raise exception 'Insufficient stock'; end if;
    update products set stock = stock - v_qty, updated_at = now() where id = v_product_id;
    v_order_item := jsonb_build_object('product_id', v_product.id, 'name', v_product.name,
      'unit_price_inr', v_product.price_inr, 'quantity', v_qty,
      'line_total_inr', v_product.price_inr * v_qty);
    v_items := v_items || jsonb_build_array(v_order_item);
    v_subtotal := v_subtotal + (v_product.price_inr * v_qty);
  end loop;
  v_total := v_subtotal + v_shipping;
  v_order_number := 'NR-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into orders(order_number, customer_name, email, phone, shipping_address, items,
                    subtotal_inr, shipping_inr, total_inr, payment_status, order_status)
  values(v_order_number, trim(p_customer_name), nullif(trim(coalesce(p_email,'')),''), trim(p_phone),
        p_shipping_address, v_items, v_subtotal, v_shipping, v_total, 'pending', 'placed')
  returning id into v_order_id;
  return jsonb_build_object('id', v_order_id, 'order_number', v_order_number,
    'subtotal_inr', v_subtotal, 'shipping_inr', v_shipping, 'total_inr', v_total,
    'payment_status', 'pending', 'order_status', 'placed');
end;
$$;
revoke execute on function public.noore_create_order(text,text,text,jsonb,jsonb) from public, anon, authenticated;
grant execute on function public.noore_create_order(text,text,text,jsonb,jsonb) to service_role;

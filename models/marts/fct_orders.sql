{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

{{ config(materialized='incremental') }}


with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('int_order_payments_pivoted') }}

),

order_date_max as (

    select max(order_date) as last_order_date
    from orders
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,

    {% for payment_method in payment_methods -%}
    {{ payment_method }}_amount,
    {% endfor -%}

    payments.total_amount as amount

    from orders
    left join payments
        on orders.order_id = payments.order_id

{% if is_incremental() %}

-- where orders.order_date > (select max(order_date) from {{ this }}) - interval '3 days'
where orders.order_date > {{ dbt.dateadd('day', -3, '(select max(order_date) from ' ~ this ~ ')') }}


{% endif %}
{% snapshot orders_snapshot %}
{{ config(
    target_schema='main',
    unique_key='id',
    strategy='check',
    check_cols=['status']
)}}

select * from {{ ref('raw_orders') }}

{% endsnapshot %}
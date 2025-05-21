-- STRING PROCESSING
-- DATABASE: FINTECH_CARDS
-- LAST_UPDATED: 18/05/2025

-- 1. Normalización de Nombres
SELECT 
    UPPER(cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name) AS nombre_cliente_mayus,
    UPPER(ml.store_name) AS nombre_tienda_mayus,
    tr.amount
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.clients cl ON cc.client_id = cl.client_id
JOIN fintech.merchant_locations ml ON tr.location_id = ml.location_id
ORDER BY tr.transaction_date DESC
LIMIT 10;

-- 2. Búsqueda de Transacciones por Categoría que contengan "Boutique"
SELECT 
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS nombre_cliente,
    tr.transaction_date,
    tr.amount
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.clients cl ON cc.client_id = cl.client_id
JOIN fintech.merchant_locations ml ON tr.location_id = ml.location_id
JOIN fintech.merchant_categories mc ON ml.category_id = mc.category_id
WHERE mc.category ILIKE '%Boutique%'
ORDER BY tr.transaction_date DESC;

-- 3. Formateo de Nombres Completos y Estado de Tarjeta
SELECT 
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS full_name,
    cc.status
FROM fintech.credit_cards cc
JOIN fintech.clients cl ON cc.client_id = cl.client_id
ORDER BY full_name;

-- 4. Identificación de Correos Electrónicos Cortos (< 15 caracteres)
SELECT 
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS nombre_cliente,
    cl.email,
    LENGTH(cl.email) AS email_length
FROM fintech.clients cl
WHERE LENGTH(cl.email) < 15
ORDER BY email_length;

-- 5. Análisis de Dominios de Correo Electrónico
SELECT 
	SPLIT_PART(email,'@',2) AS email_domain,
    COUNT(*) AS total_service_domain
FROM 
    fintech.clients
GROUP BY 
    email_domain
ORDER BY 
    total_service_domain DESC;

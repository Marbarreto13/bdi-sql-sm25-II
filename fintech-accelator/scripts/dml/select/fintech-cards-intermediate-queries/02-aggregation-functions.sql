-- AGGREGATION FUNCTIONS APPLICATIONS
-- DATABASE: FINTECH_CARDS
-- LAST_UPDATED: 16/05/2025


/**
1. Análisis de Gastos del Cliente:
Calcule los montos totales de transacciones 
por cliente dentro del período de tres meses más reciente, 
mostrando identificación del cliente y gasto total.
**/
-- FK: (transactions -> credit_cards -> clients)
SELECT
	cl.client_id,
    (cl.first_name ||' '||cl.last_name) AS cliente,
    COUNT(*) AS total_transacciones,
    SUM(tr.amount) AS total_monto
FROM 
    fintech.transactions AS tr
INNER JOIN fintech.credit_cards AS cc
    ON tr.card_id = cc.card_id
INNER JOIN fintech.clients AS cl
    ON cc.client_id = cl.client_id
WHERE 
    tr.transaction_date >= (CURRENT_DATE - INTERVAL '3 months')
GROUP BY cl.client_id, cl.first_name, cl.last_name
ORDER BY cl.client_id DESC
LIMIT 5;



/**
2. Distribución de Valor de Transacción:
Determine los valores promedio de transacciones agrupados 
por categoría de comercio y método de pago para identificar 
patrones de gasto en diferentes tipos de establecimientos.
**/

SELECT 
    pm.name AS metodo_pago,
    AVG(tr.amount) AS promedio_transacciones
FROM fintech.transactions tr
JOIN fintech.merchant_locations ml ON tr.location_id = ml.location_id
JOIN fintech.payment_methods pm ON tr.method_id = pm.method_id
GROUP BY pm.name
ORDER BY promedio_transacciones DESC;

/**
3. Distribución de Emisión de Tarjetas:
Cuantifique las tarjetas de crédito emitidas por cada institución financiera,
categorizadas por franquicia, para determinar la penetración de 
mercado por tipo de tarjeta.
**/

SELECT 
    fr.name AS franchise,
    COUNT(*) AS total_cards_issued
FROM fintech.credit_cards cc
JOIN fintech.franchises fr ON cc.franchise_id = fr.franchise_id
GROUP BY fr.name
ORDER BY total_cards_issued DESC;

/**
4. Análisis de Límites de Gasto:
Identifique los montos de transacción mínimos 
y máximos para cada cliente junto con las fechas correspondientes 
para establecer patrones de rango de gasto.
**/

-- Montos mínimo y máximo con sus fechas exactas por cliente
SELECT 
    cl.client_id,
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS nombre_cliente,
    MIN(tr.amount) AS transaccion_minima,
    MAX(tr.amount) AS transaccion_maxima,
    MIN(tr.transaction_date) AS fecha_minima_transaccion,
    MAX(tr.transaction_date) AS fecha_maxima_transaccion
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.clients cl ON cc.client_id = cl.client_id
GROUP BY cl.client_id, nombre_cliente
ORDER BY transaccion_maxima DESC
LIMIT 10;





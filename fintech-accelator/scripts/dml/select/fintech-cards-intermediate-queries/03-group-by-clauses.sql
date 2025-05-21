-- GROUP BY AND HAVING APPLICATION
-- DATABASE: FINTECH_CARDS
-- LAST_UPDATED: 16/05/202

/**
1. Identificación de Clientes de Alto Valor:
Calcule los totales de gastos de seis meses por cliente,
filtrando aquellos que superan los $7,750,424,420,346.32 (~7.75 billones),
incluyendo identificación completa del cliente y frecuencia de transacciones.
*/

SELECT 
    cl.client_id,
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS client_name,
    COUNT(tr.transaction_id) AS transaction_count,
    SUM(tr.amount) AS total_spent
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.clients cl ON cc.client_id = cl.client_id
WHERE tr.transaction_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY cl.client_id, client_name
HAVING SUM(tr.amount) > 7750424420346.32
ORDER BY total_spent DESC;

/**
2. Análisis de Rendimiento de Categoría Comercial:
Analice categorías comerciales por valor promedio de transacción
por país, filtrando categorías con transacciones promedio superiores a 
$5,497,488,250,176.02 (~5.50 billones) y mínimo 50 operaciones.
**/

SELECT
	ml.category,
  AVG(tr.amount) AS avg_transactions,
  COUNT(tr.transaction_id) AS total_operations_made,
  co.name AS country
FROM 
	fintech.merchant_locations AS ml
INNER JOIN fintech.transactions AS tr
	ON ml.location_id = tr.location_id
INNER JOIN fintech.countries AS co
	ON ml.country_code = co.country_code
--WHERE ml.country_code = 'CO' optional filter by colombia
GROUP BY ml.category, co.name
HAVING AVG(tr.amount) > 5497488250176.02
	AND COUNT(tr.transaction_id) >= 50
ORDER BY total_operations_made DESC;


/**
3. Análisis de Rechazo de Transacciones:
Determine franquicias de tarjetas con tasas elevadas de rechazo de transacciones
por país, mostrando franquicia, país y porcentaje de rechazo, 
filtrado para tasas superiores al 5% con mínimo 100 intentos de transacción.
**/

SELECT 
    fr.name AS franchise,
    co.name AS country,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE tr.status = 'Rejected') / COUNT(*), 2
    ) AS rejection_rate
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.franchises fr ON cc.franchise_id = fr.franchise_id
JOIN fintech.merchant_locations ml ON tr.location_id = ml.location_id
JOIN fintech.countries co ON ml.country_code = co.country_code
GROUP BY fr.name, co.name
HAVING COUNT(*) >= 100 AND (100.0 * COUNT(*) FILTER (WHERE tr.status = 'Rejected') / COUNT(*)) > 5
ORDER BY rejection_rate DESC;

/**
4. Distribución Geográfica del Método de Pago:
Analice los métodos de pago dominantes por ciudad, 
incluyendo nombre del método, ciudad, país y volumen de transacciones,
filtrado para métodos que representan más del 20% del volumen 
de transacciones de una ciudad.
**/

SELECT 
    pm.name AS payment_method,
    ml.city,
    ml.country_code,
    COUNT(*) AS transaction_count
FROM fintech.transactions tr
JOIN fintech.merchant_locations ml ON tr.location_id = ml.location_id
JOIN fintech.payment_methods pm ON tr.method_id = pm.method_id
GROUP BY pm.name, ml.city, ml.country_code
HAVING COUNT(*) > (SELECT COUNT(*) * 0.20
    FROM fintech.transactions tr2
    JOIN fintech.merchant_locations ml2 ON tr2.location_id = ml2.location_id
    WHERE ml2.city = ml.city)
ORDER BY ml.city, transaction_count DESC;

/**
5. Análisis de Patrones de Gasto Demográfico:
Evalúe el comportamiento de compra en demografías de género y edad,
calculando gasto total, valor promedio de transacción y frecuencia de
operación, filtrado para grupos demográficos con mínimo 30 clientes activos.
**/
SELECT 
    cl.gender,
    DATE_PART('year', AGE(cl.birth_date))::int/10*10 AS age_group,
    COUNT(DISTINCT cl.client_id) AS active_clients,
    COUNT(tr.transaction_id) AS transaction_count,
    SUM(tr.amount) AS total_spent,
    AVG(tr.amount) AS avg_transaction
FROM fintech.clients cl
JOIN fintech.credit_cards cc ON cl.client_id = cc.client_id
JOIN fintech.transactions tr ON cc.card_id = tr.card_id
GROUP BY cl.gender, age_group
HAVING COUNT(DISTINCT cl.client_id) >= 30
ORDER BY total_spent DESC;
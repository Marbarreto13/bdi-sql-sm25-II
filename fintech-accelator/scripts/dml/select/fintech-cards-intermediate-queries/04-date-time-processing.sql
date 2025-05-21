-- DATES PROCESSING APPLICATION
-- DATABASE: FINTECH_CARDS
-- LAST_UPDATED: 16/05/2025

/**
1. Análisis de Tarjetas Vencidas:
Cree una consulta que muestre todos los clientes que tienen
tarjetas de crédito vencidas a la fecha actual, 
incluyendo el nombre del cliente y la fecha de vencimiento de la tarjeta.
**/

SELECT 
    cl.client_id,
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS client_name,
    cc.expiration_date
FROM fintech.credit_cards cc
JOIN fintech.clients cl ON cc.client_id = cl.client_id
WHERE cc.expiration_date < CURRENT_DATE
ORDER BY cc.expiration_date;

/**
2. Antigüedad de Transacciones:
Desarrolle una consulta que calcule la antigüedad
de todas las transacciones completadas,
ordenándolas desde la más reciente hasta la más antigua,
mostrando el monto, el nombre del cliente y la antigüedad.
**/

SELECT 
    tr.transaction_id,
    tr.amount,
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS client_name,
    (CURRENT_DATE - tr.transaction_date) AS days_old
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.clients cl ON cc.client_id = cl.client_id
ORDER BY days_old ASC;

/**
3. Análisis de Transacciones por Mes:
Genere un informe que muestre el total de transacciones agrupadas por mes,
incluyendo el monto total y el número de transacciones por mes
**/
SELECT
	TO_CHAR(DATE_TRUNC('month', transaction_date), 'Month') as month,
	DATE_TRUNC('month', transaction_date) AS month_transaction,
	COUNT(*) total_transactions,
    SUM(amount) total_amount
   
FROM 
    fintech.transactions
GROUP BY 
    month_transaction, month
ORDER BY 
    month_transaction;

/**
4. Transacciones en las Últimas 24 Horas:
Elabore una consulta que identifique las transacciones realizadas
en las últimas 24 horas, mostrando los detalles del cliente, el comercio
y el método de pago utilizado.
**/

SELECT 
    cl.client_id,
    cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name AS client_name,
    ml.store_name AS merchant,
    pm.name AS payment_method,
    tr.amount,
    tr.transaction_date
FROM fintech.transactions tr
JOIN fintech.credit_cards cc ON tr.card_id = cc.card_id
JOIN fintech.clients cl ON cc.client_id = cl.client_id
JOIN fintech.merchant_locations ml ON tr.location_id = ml.location_id
JOIN fintech.payment_methods pm ON tr.method_id = pm.method_id
WHERE tr.transaction_date >= NOW() - INTERVAL '1 day'
ORDER BY tr.transaction_date DESC;

/**
5. Patrones de Gasto por Día de la Semana:
Construya un análisis que muestre el promedio de gasto 
por día de la semana, agrupando las transacciones por el día 
y ordenando por el promedio de gasto de mayor a menor.
**/

SELECT 
    TO_CHAR(tr.transaction_date, 'Day') AS day_of_week,
    ROUND(AVG(tr.amount), 2) AS avg_spending,
    COUNT(*) AS transaction_count
FROM fintech.transactions tr
GROUP BY day_of_week
ORDER BY avg_spending DESC;
-- JOINS APPLICATION
-- DATABASE: FINTECH_CARDS
-- LAST_UPDATED: 10/05/2025

/**
INNER JOIN: Listar todas las transacciones con detalles del cliente, 
incluyendo nombre del cliente, monto de la transacción, 
nombre del comercio y método de pago utilizado.
**/
-- JOIN (transactions -> merchant_locations -> credit_cards -> clients ->payment_methods)
SELECT 
    (cl.first_name ||' '||COALESCE(cl.middle_name, '')||' '||cl.last_name) AS client,
    tr.amount AS transaction_amount,
    ml.store_name AS purchased_store,
    pm.name AS payment_method

FROM fintech.transactions AS tr
    INNER JOIN fintech.merchant_locations AS ml
    ON tr.location_id = ml.location_id
    INNER JOIN fintech.credit_cards AS cc
    ON tr.card_id = cc.card_id
    INNER JOIN fintech.clients AS cl
    ON cl.client_id = cc.client_id
    INNER JOIN fintech.payment_methods AS pm
    ON tr.method_id = pm.method_id

LIMIT 10;
/**
LEFT JOIN: Listar todos los clientes y sus tarjetas de crédito, 
incluyendo aquellos clientes que no tienen ninguna 
tarjeta registrada en el sistema.
**/
-- LEFT JOIN (clients -> credit_cards)
SELECT 
    (cl.first_name || ' ' || COALESCE(cl.middle_name, '') || ' ' || cl.last_name) AS client,
    cc.card_id AS credit_card_number,
    cc.issue_date

FROM fintech.clients AS cl
    LEFT JOIN fintech.credit_cards AS cc
    ON cl.client_id = cc.client_id

LIMIT 10;


/**
RIGHT JOIN: Listar todas las ubicaciones comerciales y las transacciones 
realizadas en ellas, incluyendo aquellas ubicaciones donde 
aún no se han registrado transacciones.
**/
-- RIGHT JOIN (transactions -> merchant_locations)
SELECT 
    ml.store_name AS store,
    tr.transaction_id,
    tr.amount AS transaction_amount,
    tr.transaction_date

FROM fintech.transactions AS tr
    RIGHT JOIN fintech.merchant_locations AS ml
    ON tr.location_id = ml.location_id

LIMIT 10;

/**
FULL JOIN: Listar todas las franquicias y los países donde operan, 
incluyendo franquicias que no están asociadas a ningún país 
específico y países que no tienen franquicias operando en ellos.
**/
-- FULL JOIN (franchises -> countries)
SELECT 
    fr.name AS franchise_name,
    co.name AS country_name

FROM fintech.franchises AS fr
    FULL JOIN fintech.countries AS co
    ON fr.country_code = co.country_code

LIMIT 10;

/**
SELF JOIN: Encontrar pares de transacciones realizadas por el mismo 
cliente en la misma ubicación comercial en diferentes
**/
-- SELF JOIN (transactions t1, t2 del mismo cliente y ubicación, pero distinta fecha)
SELECT 
    t1.transaction_id AS transaction_1_id,
    t1.card_id AS card_id,
    t1.location_id AS location_id,
    t1.amount AS transaction_1_amount,
    t1.transaction_date AS transaction_1_date,
    t2.transaction_id AS transaction_2_id,
    t2.amount AS transaction_2_amount,
    t2.transaction_date AS transaction_2_date
FROM fintech.transactions t1
    INNER JOIN fintech.transactions t2
        ON t1.card_id = t2.card_id
        AND t1.location_id = t2.location_id
        AND t1.transaction_id < t2.transaction_id
LIMIT 10;




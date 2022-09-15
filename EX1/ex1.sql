/* 
MAC0426 - Sistemas de Bancos de Dados - Exercício 1
Nome: João Henri Carrenho Rocha
NUSP: 11796378

Obs: as consultas foram testadas na versão 14.1 do PostgreSQL.
*/


-- a) Liste os nomes dos agricultores de Mogi das Cruzes.
SELECT a.nomea
FROM agricultor a
WHERE a.cidadea = 'Mogi das Cruzes';

-- b) Liste todas as informações de todo produto cujo nome começa com as letras de “a” a “e” ou
-- cujo preço por quilo está entre R$2,00 e R$3,00.
SELECT *
FROM produto p
WHERE (p.nomep >= 'a'
       AND p.nomep <= 'e')
   OR (p.precoquilo >= 2
       AND p.precoquilo <= 3);

-- c) Liste os códigos dos produtos que já foram entregues por agricultores de sobrenome “Bandeira”.
SELECT a.coda
FROM agricultor a
WHERE a.nomea like '%Bandeira%';

-- d) Liste os nomes dos restaurantes que já receberam entregas de cebola
SELECT DISTINCT(r.nomer)
FROM entrega e
INNER JOIN produto p ON p.codp = e.codp
INNER JOIN restaurante r ON e.codr = r.codr
WHERE p.nomep = 'cebola';

-- e) Liste os códigos dos agricultores que já entregaram cebolas e também já entregaram batatas.
WITH entregaram_batata AS (
    SELECT a.coda
    FROM entrega e
    INNER JOIN agricultor a ON a.coda = e.coda
    INNER JOIN produto p ON p.codp = e.codp
    WHERE p.nomep = 'batata'
),
entregaram_cebola AS (
    SELECT a.coda
    FROM entrega e
    INNER JOIN agricultor a ON a.coda = e.coda
    INNER JOIN produto p ON p.codp = e.codp
    WHERE p.nomep = 'cebola'
)
SELECT DISTINCT(eb.coda)
FROM entregaram_batata eb
INNER JOIN entregaram_cebola ec on ec.coda = eb.coda;

-- f) Liste os códigos dos agricultores que já entregaram cebolas, mas nunca entregaram batatas
WITH entregaram_cebola AS (
    SELECT a.coda
    FROM entrega e
    INNER JOIN agricultor a ON a.coda = e.coda
    INNER JOIN produto p ON p.codp = e.codp
    WHERE p.nomep = 'cebola'
)
SELECT DISTINCT(ec.coda) FROM entregaram_cebola ec 
WHERE ec.coda NOT IN (
    SELECT a.coda
    FROM entrega e
    INNER JOIN agricultor a ON a.coda = e.coda
    INNER JOIN produto p ON p.codp = e.codp
    WHERE p.nomep = 'batata'
);

-- g) Liste todas as triplas (código do agricultor, código do produto, código do restaurante) extraídas
-- de Entrega tais que o agricultor e o restaurante não estejam na mesma cidade.
SELECT e.coda, e.codp, e.codr
FROM entrega e
INNER JOIN restaurante r ON r.codr = e.codr
INNER JOIN agricultor a ON a.coda = e.coda
WHERE a.cidadea <> r.cidader;

-- h) Obtenha a quantidade total em kg de produtos já entregues ao restaurante RU-USP.
SELECT SUM(e.qtdequilos)
FROM entrega e
INNER JOIN restaurante r ON r.codr = e.codr
WHERE r.nomer = 'RU-USP';

-- i) Liste os nomes das cidades que tenham pelo menos dois agricultores.
SELECT cidadea,
       count(*)
FROM agricultor a
GROUP BY cidadea
HAVING count(*) >= 2;

-- j) Obtenha o número de produtos que são fornecidos ou por um agricultor de São Paulo ou para
-- um restaurante em São Paulo.
SELECT COUNT(DISTINCT(e.codp))
FROM entrega e
INNER JOIN agricultor a ON a.coda = e.coda
INNER JOIN restaurante r ON r.codr = e.codr
WHERE a.cidadea = 'São Paulo'
  OR r.cidader = 'São Paulo';

-- k) Obtenha pares do tipo (código do restaurante, código do produto) tais que o restaurante
-- indicado nunca tenha recebido o produto indicado.
WITH produtos_recebidos_por_restaurante AS
  (SELECT DISTINCT e.codp,
                   e.codr
   FROM entrega e
   INNER JOIN restaurante r ON r.codr = e.codr)
SELECT DISTINCT r.nomer,
                p.nomep
FROM entrega e
INNER JOIN restaurante r ON r.codr = e.codr
CROSS JOIN produto p
WHERE (p.codp,
       e.codr) not in
    (SELECT prpr.codp,
            prpr.codr
     FROM produtos_recebidos_por_restaurante prpr)
ORDER BY r.nomer,
         p.nomep;

-- l) Obtenha o(s) nome(s) dos produtos mais fornecidos a restaurantes (ou seja, os produtos dos
-- quais as somas das quantidades já entregues é a maior possível). 
WITH qtd_total_entregue_produto AS (
    SELECT p.nomep,
        sum(qtdequilos) AS qtd_total_entregue
    FROM entrega e
    INNER JOIN produto p ON p.codp = e.codp
    GROUP BY p.codp
)
SELECT q.nomep, q.qtd_total_entregue 
  FROM qtd_total_entregue_produto q
 WHERE q.qtd_total_entregue IN (
    SELECT max(qtd_total_entregue) FROM qtd_total_entregue_produto
);

-- m) Obtenha o nome do(s) restaurante(es) que recebeu(receberam) a entrega de produtos mais
-- recente registrada no BD.
SELECT r.nomer
FROM entrega e
INNER JOIN restaurante r ON r.codr = e.codr WHERE e.dataentrega in
  (SELECT max(dataentrega)
   FROM entrega);

-- n) Liste todos os pares possíveis do tipo (i,j) tal que i é o nome de um produto, j é o nome de um
-- agricultor que já entregou i. Mas atenção: o nome de todos os produtos cadastrados no BD deve
-- aparecer no conjunto resposta. Se um produto nunca foi entregue, então o seu nome deve vir
-- acompanhado de NULL no conjunto resposta. A resposta deve aparecer em ordem decrescente
-- de nome de produto. 
SELECT DISTINCT p.nomep,
                a.nomea
FROM entrega e
INNER JOIN agricultor a ON a.coda = e.coda
RIGHT JOIN produto p ON p.codp = e.codp
ORDER BY p.nomep;
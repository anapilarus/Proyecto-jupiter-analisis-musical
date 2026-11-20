USE proyecto_musical;
select * from artistas_cancion;
select * from cancion;
select * from favoritos;
select * from fecha_publicacion;
select * from id_artistas;
select * from id_disco;
select * from id_discografica;
select * from id_genero;
select * from listas;
select * from popularidad;

-- ============================================================
-- KPIs DEL ENUNCIADO
-- ============================================================


-- 1. Calcular la media diaria de reproducciones durante el mes de septiembre
SELECT round(SUM(reproducciones) / 30,2) AS media_diaria
FROM popularidad;

-- La media diaria de reproducciones durante el mes de septiembre es 46921854.40
-- Resuelto por Ana


-- 2. Calcular el número total de reproducciones
SELECT sum(reproducciones) AS num_reproducciones 
FROM popularidad;

-- El número total de reproducciones es 1407655632
-- Resuelto por Gema


-- 3. ¿Qué días del mes se han reproducido más canciones y cuántas?
select dia, count(distinct id_cancion) as total_canciones_distintas
from popularidad
group by dia
order by total_canciones_distintas desc
limit 5;

-- Los 5 días del mes en los que más canciones se han reproducido:
-- día 7	    990 canciones reproducidas
-- día 10	988 canciones reproducidas
-- día 17	987 canciones reproducidas
-- día 11	986 canciones reproducidas
-- día 12	986 canciones reproducidas
-- Resuelto por Alejandro


-- 4. ¿Qué día del mes suelen publicarse más canciones y cuántas?
SELECT DAY(fecha_publicacion) AS dia, COUNT(*) AS total_canciones
FROM fecha_publicacion
WHERE fecha_publicacion IS NOT NULL
GROUP BY DAY(fecha_publicacion)
HAVING COUNT(*) = (
    SELECT MAX(total)
    FROM (
        SELECT COUNT(*) AS total
        FROM fecha_publicacion
        WHERE fecha_publicacion IS NOT NULL
        GROUP BY DAY(fecha_publicacion)
    ) AS subconsulta
);

-- Día 20 con 38 reproducciones
-- Resuelto por Miriam


-- 5. ¿Cuáles son los 5 usuarios que más canciones han añadido a favoritos y cuántas?
SELECT
    usuario,
    COUNT(id_cancion) AS total_favoritos
FROM favoritos
GROUP BY usuario
ORDER BY total_favoritos DESC
LIMIT 5;

-- Resultado: Los 5 usuarios que más canciones han añadido a favoritos son: 
-- ivk_58:	9 canciones
-- clp_71:	8 canciones
-- aqi_45:	8 canciones
-- fox_11:	8 canciones
-- ayy_86:	8 canciones
-- Resuelto por Ana


-- 6. ¿Cuáles son los 5 usuarios que menos canciones han añadido a favoritos y cuántas?
SELECT usuario, count(id_cancion) AS num_favoritos 
FROM favoritos
GROUP BY usuario
ORDER BY num_favoritos ASC
LIMIT 5;

-- Los 5 usuarios con menos canciones añadidas a favoritas son aaa_0, aaa_11, aaa_12, aaa_14 y aaa_17; solo han añadido una canción
-- En realidad hay muchos mas usuarios que solo han añadido una canción pero solo hemos mostrado los 5 primeros
-- Resuelto por Gema


-- 7. ¿Cuáles son las 10 discográficas que han recibido más dinero y cuánto?
select discografica, sum(c.coste) as dis_mas_dinero
from id_discografica d
left join cancion c on d.id_discografica = c.id_discografica
group by d.discografica, d.id_discografica
order by dis_mas_dinero DESC
limit 10;

-- Las 10 discográficas que más dinero han recibido son:
-- Merge Records	236167€
-- 4AD	124075€
-- Interscope Records	120573€
-- RCA Records	115938€
-- XL Recordings	108948€
-- Sun Records	108788
-- Wind-Up Records	108226
-- Arista Records	105815
-- Atlantic Records	105256
-- Rough Trade Records	103375
-- Resuelto por Alejandro


-- 8. ¿Cuáles son los 3 artistas que más colaboraciones con otros artistas han hecho?
SELECT artista, colaboraciones
FROM (
    SELECT ia.artista, COUNT(*) AS colaboraciones,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
    FROM artistas_sql ac
    JOIN id_artistas ia ON ac.id_artista = ia.id_artista
    WHERE ac.id_cancion IN (
        SELECT id_cancion
        FROM artistas_sql
        GROUP BY id_cancion
        HAVING COUNT(*) > 1
    )
    GROUP BY ia.id_artista, ia.artista
) AS subconsulta
WHERE ranking <= 3;

-- 1. J.Cole con 8 colaboraciones
-- 2. Eric Clapton con 7 colaboraciones
-- 3. Katy Perry con 7 colaboraciones
-- Resuelto por Miriam


-- 9. ¿Cuáles son los 3 artistas que han interpretado menos canciones de otros compositores?
SELECT
    a.id_artista,
    a.artista,
    COUNT(*) AS canciones_de_otros
FROM artistas_cancion ac
JOIN cancion c
    ON ac.id_cancion = c.id_cancion
JOIN id_artistas a
    ON ac.id_artista = a.id_artista
WHERE ac.id_artista <> c.id_autor
GROUP BY a.id_artista, a.artista
ORDER BY canciones_de_otros ASC
LIMIT 3;

-- Resultado: Los 3 artistas que han interpretado menos canciones de otros compositores son:
-- Bessie Smith 1 canción de otros
-- Lead Belly 1 canción de otros
-- Jimi Hendrix 1 canción de otros
-- Resuelto por Ana


-- 10. ¿Cuántas canciones de cada género hay?
SELECT g.genero, count(c.cancion) AS num_canciones 
FROM cancion c 
LEFT JOIN id_genero g ON c.id_genero = g.id_genero
GROUP BY g.genero;

-- Hay 100 canciones en cada género
-- Resuelto por Gema


-- 11. ¿Cuáles son los discos más escuchados?
select disco, sum(p.reproducciones) as discos_mas_escuchados
from id_disco d
left join cancion c on d.id_disco=c.id_disco
left join popularidad p on c.id_cancion=p.id_cancion
group by d.id_disco,d.disco
order by discos_mas_escuchados DESC
limit 5;

-- Los 5 discos más escuhados son:
-- jazz3	19378099 reproducciones
-- country2	16786470 reproducciones
-- metal9	15455461 reproducciones
-- classical8	15308862 reproducciones
-- jazz9	14935137 reproducciones
-- Resuelto por Alejandro


-- 12. ¿Cuál es la media de canciones que tiene un disco?
SELECT ROUND(COUNT(*) / COUNT(DISTINCT id_disco), 2) AS media_canciones_por_disco
FROM cancion;

-- 5 canciones por disco
-- Resuelto por Miriam


-- 13. ¿Cuál es la cuantía total de cada tipo de canción que cobran las 5 discográficas que han recibido más dinero?
WITH top5_discograficas AS (
    SELECT
        id_discografica,
        SUM(coste) AS total_recibido
    FROM cancion
    GROUP BY id_discografica
    ORDER BY total_recibido DESC
    LIMIT 5
)

SELECT
    d.discografica,
    g.genero,
    SUM(c.coste) AS cuantia_total
FROM cancion c
JOIN top5_discograficas t
    ON c.id_discografica = t.id_discografica
JOIN id_discografica d
    ON c.id_discografica = d.id_discografica
JOIN id_genero g
    ON c.id_genero = g.id_genero
GROUP BY
    d.id_discografica,
    d.discografica,
    g.id_genero,
    g.genero
ORDER BY
    d.discografica,
    cuantia_total DESC;

-- Resultado: La cuantía total de cada tipo de canción (género) que cobran las 5 discográficas que han recibido más dinero es:
-- 4AD: hiphop	29721; country	23651; rock	14976; jazz	13327; disco 10860; reggae	10193; metal 9311; blues 5491; classical 3608; pop	2937
-- Interscope Records: jazz 27343; classical 16982; blues 11771; metal 11235; pop	11084; rock	9860; disco	9822; country 8029; hiphop 7874; reggae 6573
-- Merge Records: rock	36150; country	33188; classical 32007; blues 31215; reggae	26702; hiphop 22273; jazz 21483; pop 12299; metal 10542; disco	10308
-- RCA Records: pop	19638; jazz	15580; blues	13744; reggae	13018; rock	12973; country	11920; hiphop	9919; classical	8483; metal	5648; disco	5015; reggae	23169
-- XL Recordings: disco	18361; hiphop	14758; classical	13536; pop	12030; rock	10302; blues	5495; metal	4726; jazz	4446; country	2125
-- Resuelto por Ana


-- 14. Para cada disco calcular la duración total
SELECT d.disco, sum(TIME_TO_SEC(c.duracion)) AS dur_seg_disco 
FROM id_disco d 
LEFT JOIN cancion c ON c.id_disco = d.id_disco
GROUP BY d.disco
ORDER BY dur_seg_disco DESC;

-- Resultado: 
-- classical8 2187, jazz3 2175, pop16 2141, metal19 2132, reggae18 1923, pop6 1921, pop5 1716, metal1 1619, 
-- metal9 1574, reggae17 1536, classical1 1529, country19 1501, blues0 1500, metal16 1481, blues14 1413, 
-- country0 1406, rock11 1377, disco12 1333, rock5 1332, pop11 1328, blues12 1300, jazz19 1299, country2 1293, 
-- jazz0 1292, blues7 1272, reggae10 1255, classical10 1238, jazz9 1237, reggae14 1224, metal10 1214, country13 1149, 
-- hiphop3 1144, country7 1141, metal14 1131, hiphop14 1130, classical12 1124, rock1 1103, blues16 1101, rock12 1096,
-- reggae13 1082, reggae3 1080, jazz8 1071, country18 1056, rock17 1039, rock18 1037, jazz7 1036, hiphop12 1021, 
-- hiphop19 1020, country17 1018, disco6 1003, reggae1 1003, pop19 995, country10 973, reggae6 973, reggae7 956, 
-- blues2 944, disco4 932, classical15 931, rock10 921, disco9 919, country6 907, jazz13 903, disco0 899, rock7 878, 
-- blues13 873, classical13 866, reggae9 866, country1 862, pop8 846, rock4 842, disco15 838, metal5 831, 
-- country3 826, hiphop6 821, hiphop10 808, metal8 806, hiphop13 805, metal12 799, pop18 799, disco3 797, metal0 776, 
-- hiphop0 770, hiphop11 765, hiphop1 765, jazz1 764, pop0 762, hiphop16 759, blues17 756, classical4 753, 
-- disco10 752, metal13 752, hiphop17 746, rock19 726, classical6 725, disco2 723, rock13 719, disco19 702, 
-- hiphop5 702, disco18 698, reggae2 683, rock3 683, reggae12 681, classical19 674, reggae4 673, disco8 664, 
-- classical14 660, pop14 656, classical7 655, pop1 655, blues15 653, disco13 650, classical11 643, metal2 638, 
-- disco16 637, blues4 635, blues5 631, jazz14 623, disco1 619, country14 616, classical2 603, blues6 602, jazz18 597,
-- metal15 597, pop7 597, pop15 592, metal11 580, rock8 571, pop3 570, jazz12 565, hiphop2 557, blues11 538, 
-- disco17 535, metal4 535, rock2 535, reggae11 521, pop10 514, country9 512, reggae16 502, classical18 501, 
-- jazz2 500, jazz16 497, disco5 494, blues9 483, rock0 482, pop2 479, classical9 477, blues19 466, country12 462, 
-- hiphop15 462, blues18 461, rock16 459, metal7 445, hiphop8 437, jazz5 433, reggae8 428, classical0 427, disco11 426, 
-- classical16 422, pop17 421, hiphop18 415, hiphop4 411, jazz15 408, disco14 401, metal6 399, blues8 398, 
-- reggae15 398, blues3 396, jazz6 389, jazz11 377, country5 372, metal18 371, hiphop7 370, country11 356, pop12 356, 
-- pop4 353, pop9 350, reggae19 342, rock6 340, hiphop9 318, rock15 316, classical17 306, country16 276, 
-- country15 262, jazz10 256, jazz4 248, classical3 236, classical5 232, reggae5 232, blues10 230, jazz17 209,
-- country8 193, blues1 191, disco7 190, country4 176, metal3 171, metal17 164, rock14 156, rock9 129, pop13 111, reggae0 99
-- Resuelto por Gema


-- 15. Calcular la media de duración de los discos
select sec_to_time(round(avg(duracion_total))) as media_duracion_discos
from (
    select
        d.id_disco,
        sum(time_to_sec(c.duracion)) as duracion_total
    from id_disco d
    join cancion c on d.id_disco = c.id_disco
    group by d.id_disco
) as tabla_duracion;

-- La media de duración de los discos es 12 minutos 45 segundos.
-- Resuelto por Alejandro



-- ============================================================
-- RESTO DE KPIs CALCULADOS POR EL GRUPO
-- ============================================================


-- 16. Calcular la media diaria de reproducciones durante el mes de septiembre por canción
SELECT
    id_cancion,
    ROUND(SUM(reproducciones) / 30, 2) AS media_diaria
FROM popularidad
GROUP BY id_cancion
ORDER BY media_diaria DESC;

-- Resultado: Media diaria de reproducciones durante el mes de septiembre por canción, adjunto las 5 primeras del resultado final pues son 1000 canciones en total:
-- 907	rock.00006.wav	62805.80 reproducciones
-- 709	pop.00008.wav	62572.60 reproducciones
-- 192	classical.00091.wav	62368.83 reproducciones
-- 73	blues.00072.wav	61516.93 reproducciones
-- 66	blues.00065.wav	61472.60 reproducciones

-- Resuelto por Ana


-- 17. Calcular la media de reproducciones en el mes de septiembre por género
SELECT
    g.genero,
    ROUND(SUM(p.reproducciones) / 30, 2) AS media_diaria
FROM popularidad p
JOIN cancion c
    ON p.id_cancion = c.id_cancion
JOIN id_genero g
    ON c.id_genero = g.id_genero
GROUP BY g.genero
ORDER BY media_diaria DESC;

-- Resultado: La media diaria de reproducciones durante el mes de septiembre por género es:
-- blues	4755570.37 reproducciones
-- classical	4750474.57 reproducciones
-- pop	4738120.07 reproducciones
-- disco	4723809.43 reproducciones
-- country	4718832.40 reproducciones
-- hiphop	4706216.17 reproducciones
-- jazz	4705417.77 reproducciones
-- rock	4648398.30 reproducciones
-- metal	4599345.50 reproducciones
-- reggae	4575669.83 reproducciones

-- Resuelto por Ana


-- 18. Canción más escuchada en cuántas listas está
select mas_escuchada.cancion, mas_escuchada.cancion_mas_escuchada, count(distinct l.lista) as numero_listas
from (
    select 
        c.id_cancion,
        c.cancion,
        sum(p.reproducciones) as cancion_mas_escuchada
    from cancion c
    join popularidad p 
        on c.id_cancion = p.id_cancion
    group by c.id_cancion, c.cancion
    order by cancion_mas_escuchada desc
    limit 1
) as mas_escuchada
left join listas l 
    on mas_escuchada.id_cancion = l.id_cancion
group by 
    mas_escuchada.id_cancion, mas_escuchada.cancion, mas_escuchada.cancion_mas_escuchada;

-- La canción más escuchada se encuentra en 25 listas.
-- rock.00006.wav, 1884174, veces escuchada y en 25 listas
-- Resuelto por Alejandro


-- 19. Canción más escuchada por género en todo el año
with reproducciones_por_cancion as (

    select
        g.id_genero,
        g.genero,
        c.id_cancion,
        c.cancion,
        sum(p.reproducciones) as total_reproducciones
    from id_genero g
    join cancion c
        on g.id_genero = c.id_genero
    join popularidad p
        on c.id_cancion = p.id_cancion
    group by
        g.id_genero,
        g.genero,
        c.id_cancion,
        c.cancion
),

maximos_por_genero as (

    select
        id_genero,
        max(total_reproducciones) as max_reproducciones
    from reproducciones_por_cancion
    group by id_genero
)

select
    r.genero,
    r.cancion,
    r.total_reproducciones
from reproducciones_por_cancion r
join maximos_por_genero m
    on r.id_genero = m.id_genero
    and r.total_reproducciones = m.max_reproducciones
order by r.genero;

-- Canciones más escuhadas por género:
-- blues	blues.00072.wav	1845508
-- classical	classical.00091.wav	1871065
-- country	country.00002.wav	1732479
-- disco	disco.00084.wav	1750799
-- hiphop	hiphop.00089.wav	1782082
-- jazz	jazz.00009.wav	1728861
-- metal	metal.00072.wav	1704054
-- pop	pop.00008.wav	1877178
-- reggae	reggae.00004.wav	1758428
-- rock	rock.00006.wav	1884174
-- Resuelto por Alejandro


-- 20. ¿Cuál es el género más escuchado?
SELECT g.genero, sum(p.reproducciones) AS num_reproducciones 
FROM id_genero g 
INNER JOIN cancion c ON c.id_genero = g.id_genero
INNER JOIN popularidad p ON p.id_cancion = c.id_cancion
GROUP BY g.genero
ORDER BY num_reproducciones DESC
LIMIT 1;

-- Blues es el género mas escuchado
-- Resuelto por Gema


-- 21. Porcentaje de canciones reproducidas más de 1.500.000 veces
WITH num_canciones as (
select count(*) as total FROM cancion),

num_canciones_rep as (SELECT COUNT(*) AS canciones_rep FROM (SELECT c.cancion, sum(p.reproducciones) AS num_reproducciones 
FROM cancion c 
INNER JOIN popularidad p ON p.id_cancion = c.id_cancion
GROUP BY c.cancion
HAVING num_reproducciones > 1500000) A)

select (canciones_rep/total)*100 as porcentaje
from num_canciones_rep, num_canciones;

-- El 30,2%
-- Resuelto por Gema


-- 22. ¿Cuál es el artista más escuchado?
SELECT artista, total_reproducciones
FROM (
    SELECT ia.artista, SUM(p.reproducciones) AS total_reproducciones,
           RANK() OVER (ORDER BY SUM(p.reproducciones) DESC) AS ranking
    FROM popularidad p
    JOIN cancion c ON p.id_cancion = c.id_cancion
    JOIN id_artistas ia ON c.id_autor = ia.id_artista
    GROUP BY ia.id_artista, ia.artista
) AS subconsulta
WHERE ranking = 1;

-- Eric Clapton con 15378780 reproducciones
-- Resuelto por Miriam


-- 23. Media de la duración de las canciones
SELECT SEC_TO_TIME(AVG(TIME_TO_SEC(duracion))) AS media_duracion
FROM cancion
WHERE duracion IS NOT NULL;

-- 00:02:35.8869 minutos
-- Resuelto por Miriam


-- 24. Media que se le paga a las discográficas
SELECT ROUND(AVG(c.coste), 2) AS media_pago_discografica
FROM cancion c;

-- La media que se paga a las discográficas es 2998.78 euros
-- Resuelto por Miriam

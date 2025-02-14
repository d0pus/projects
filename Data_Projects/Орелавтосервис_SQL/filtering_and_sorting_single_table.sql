/*15.	 Найти российские автомобильные заводы, у которых почтовый и фактический адреса совпадают. Сформировать список с именами, фактическими адресами и кон-тактными телефонами предприятий. 
Ответ: 2 строки, 3 столбца.*/

SELECT factory_name, legal_addr, phone 
FROM factory 
WHERE post_addr = legal_addr
 AND legal_addr LIKE '%Россия%';

/*16.	 Составить список механиков, имеющих трудовой стаж (столбец certif_date) более 13 лет. Выдать фамилии и инициалы механиков, даты выдачи сертификатов и прие-ма на работу, трудовой стаж (полных лет), отсортировать список по возрастанию трудового стажа. 
Ответ: 15 строк (для запроса в 2022 году), 4 столбца.*/

SELECT sname_initials, certif_date, work_in_date, EXTRACT(YEAR FROM AGE(certif_date)) as experience 
FROM mechanic 
WHERE EXTRACT(YEAR FROM age(certif_date)) > 13 
ORDER BY experience ASC;

/*17.	 Найти автомобили, для которых НДС, уплаченный при приобретении, превос-ходит 500 000 рублей (НДС рассчитывается по ставке 18% от суммы платежа). Вы-дать государственные номерные знаки, суммы и даты поступления уплаченного НДС. Выдачу отсортировать по уменьшению суммы уплаченного НДС.
Ответ: 35 строк, 3 столбца. 
Расчет суммы налогов дает значение 44 795 649 руб. 60 коп.*/

SELECT gnz, SUM(cost) * 0.18 AS nds, date_use 
FROM vehicle 
GROUP BY gnz, date_use 
HAVING SUM(cost) * 0.18 > 500000 
ORDER BY SUM(cost) * 0.18 DESC;

SELECT SUM(nds) AS itog
FROM (
   SELECT gnz, SUM(cost) * 0.18 AS nds, date_use 
   FROM vehicle 
   GROUP BY gnz, date_use 
   HAVING SUM(cost) * 0.18 > 500000 
) AS test;

/*18.	 Сформировать список автомобилей, зарегистрированных не в Орловской обла-сти. Вывести государственный номерной знак, серию, номер и дату выдачи свиде-тельства о регистрации транспортного средства. Отсортировать данные по региону регистрации, по убыванию.
Ответ: 15 строк, 4 столбца. В запросе следует учесть, что код региона Орловской области может быть любым из множества {57,  157, 757}.*/

SELECT gnz, ser$reg_certif, num$reg_certif, date$reg_certif
FROM vehicle
WHERE substring(gnz from 7)::INTEGER NOT IN (57, 157, 757)
ORDER BY st_id DESC;

/*19.	 Найти работы, выполненные в выходные дни (субботу и воскресенье). Выдать государственные номерные знаки автомобилей, даты проведения работ, дни недели, в которые они проводились, и технические заключения по их результатам (tech_cond_resume). 
Ответ: 182 строки, 4 столбца. 95 работ проведено в воскресенье, остальные – в суб-боту.*/

SELECT gnz, date_work, 
   TO_CHAR(date_work, 'Day') AS week_day, 
   tech_cond_resume 
FROM maintenance 
WHERE extract(isodow from date_work) IN (6, 7);

/*20.	 Сформировать список работ, проведенных в выходные дни (кроме празднич-ных), по которым не сформировано техническое заключение специалиста.
Ответ: 7 строк, 4 столбца.*/

SELECT gnz, date_work, 
  TO_CHAR(date_work, 'Day') AS week_day, 
  tech_cond_resume 
FROM maintenance 
WHERE EXTRACT(isodow from date_work) IN (6, 7) 
  AND tech_cond_resume IS NULL;

/*21.	 Найти наименования отечественных моделей автомобилей, сформированных в соответствие с советским ГОСТ классификации и кодирования (кодировка номера модели имеет четыре разряда). 
Ответ: 21 строка, 1 столбец.*/

SELECT model_name 
FROM model 
WHERE substring(model_name FROM 1 FOR 3) IN ('ГАЗ','ВАЗ','ПАЗ') 
 AND length(substring(model_name FROM 5)) = 4;

/*22.	 Выдать фамилии, инициалы механиков с фамилиями, начинающимися на буквы "С", "К", "Л" с упорядочением результирующей выборки по фамилии. 
Ответ: 13 строк (по четыре на каждую букву "С" и "К", пять – на букву "Л"), 1 столбец.*/

SELECT sname_initials
FROM mechanic
WHERE sname_initials LIKE 'С%'
OR sname_initials LIKE 'К%'
OR sname_initials LIKE 'Л%'
ORDER BY sname_initials;

/*23.	 Найти автомобильные заводы, в названиях или почтовых адресах или фактиче-ских адресах которых встречается символ подчеркивания "_" (использовать преди-кат LIKE с конструкцией ESCAPE). Выдать названия юридических лиц, их почтовые и фактические адреса и телефоны. 
Ответ: 1 строки, 4 столбца. Предприятие "Bavarischen motorwerke ainth"*/

SELECT factory_name,
post_addr,
legal_addr,
phone 
FROM factory 
WHERE factory_name LIKE '%\_%' ESCAPE '\' 
OR post_addr LIKE '%\_%' ESCAPE '\' 
OR legal_addr LIKE '%\_%' ESCAPE '\';

/*24.	 Определить, когда последний раз проводилось обслуживание автомобиля с гос-ударственным номерным знаком 'c910ca57'. Результат представить в виде даты в формате "день.месяц.год" с указание тысячелетия (четырехразрядное обозначение года).
Ответ: 28.01.2019.*/

SELECT TO_CHAR(date_work, 'DD.MM.YYYY')
FROM maintenance
WHERE gnz = 'c910ca57'
ORDER BY date_work DESC
LIMIT 1;

/*25.	 Определить автомобили, которые в 2016 году посетили предприятие для обслу-живания или ремонта. 
Ответ: 44 строки, 1 столбец.*/

SELECT gnz
FROM maintenance
WHERE EXTRACT(year from date_work) = 2016
GROUP BY gnz;

/*26.	 Найти технические заключения, серия которых состоит только из цифр. Выдать серии, номера заключений и даты выполнения работ. 
Ответ: 30 строк, 3 столбца.*/

SELECT s$diag_chart,
 n$diag_chart,
 date_work
FROM maintenance
WHERE s$diag_chart ~ '^[0-9]+$';

/*27.	 Найти технические заключения о проведенных работах, которые в серии имеют буквосочетание "ТО" в любом регистре, на любой позиции, выданные на работы, проведенные в 2019 году. Выдать серии и номера технических заключений через пробел в одном столбце. 
Ответ: 96 строк, 1 столбец.*/

SELECT CONCAT(s$diag_chart, ' ', n$diag_chart) AS "ТО"
FROM maintenance
WHERE EXTRACT(year FROM date_work) = 2019
AND s$diag_chart ILIKE '%ТО%';

/*28.	 Найти работы, выполненные в последний день месяца (учитывать високосные го-ды). Выдать серии и номера технических заключений, даты (без указания времени) проведения работ, содержание заключения. 
Ответ: 19 строк, 4 столбца.*/

SELECT s$diag_chart,
n$diag_chart,
TO_CHAR(date_work, 'dd.MM.yyyy'),
tech_cond_resume
FROM maintenance
WHERE EXTRACT(day from date_work) = EXTRACT(day from (DATE_TRUNC('MONTH', date_work) + INTERVAL '1 MONTH - 1 day')::DATE);

/*29.	 Найти автомобили, зарегистрированные за пределами Орловской области (код региона государственного номерного знака не входит во множество {57, 157, 757}). Выдать государственные номерные знаки, даты изготовления, даты начала эксплуа-тации, серии, номера и даты выдачи свидетельств о регистрации транспортных средств. Результат отсортировать по дате начала эксплуатации.
Ответ: 15 строк, 6 столбцов.*/

SELECT gnz,
 date_made,
 date_use,
 ser$reg_certif,
 num$reg_certif,
 date$reg_certif
FROM vehicle
WHERE SUBSTRING(gnz FROM 7)::INTEGER NOT IN (57, 157, 757)
ORDER BY date_use;

/*30.	 Сформировать сортированный список государственных номерных знаков заре-гистрированных автомобилей с добавлением столбца с порядковым номером запи-си, с названием "id_row".
Ответ: 161 строка, 2 столбца.*/

SELECT gnz,
 ROW_NUMBER() OVER (ORDER BY gnz) AS id_row
FROM vehicle
ORDER BY gnz;

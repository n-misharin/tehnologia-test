# Задание 1

## Условие

Написать программу на Java для копирования class-файлов из заданного каталога в структуру каталогов в
соответствии с полным названием java-класса.

## Решение

Код решения находится в файле `src/UpdateClassFile.java`. При запуске копирует class-файлы из каталога `task/update` в
каталог `task` (каталог `com` тоже там).

# Задание 2

Написать SQL-запрос, который вернет список объектов (`id_object`) где умер последний
собственник более указанного количества месяцев и на момент смерти последнего собственника не
было ни одного живого зарегистрированного (`id_residence_type=1`). При реализации следует учесть,
что задание сформулировано так что должны корректно обрабатывается ситуация, когда человек
умирает например 01.01.2005, а его выписывают 25.01.2005 (или забывают выписать).

## Решение

Сам файл с запросом находится в `sql/solution.sql`.

## Ход решения задачи на SQL

В условии написано "На основании персональных документов контрагенты ... получают право собственности на объекты.". Т.е.
есть таблица "personal_doc_property" (Подтверждение права на объект), в которой можно найти всех собственников объекта.
Будем считать что записи из этой таблице не удаляются, поэтому прошлые собственники там тоже присутствуют. Однако, в
этой таблице нет даты, когда это право собственности вступает в силу. Наверно, эта дата есть в каком-то персональном
документе (`personal_doc`), который связан с записью в таблице `personal_doc_property`. Получается, чтобы найти одного
из последних (судя по таблице `personal_doc_property` собственников может быть несколько, каждый из которых владеет
какой-то частью объекта) собственников определенного объекта, нужно в таблице с подтверждениями права на
объект (`personal_doc_property`) найти запись, которая связана персональным документом (`personal_doc`) с максимальной
датой начала действия документа (`personal_doc.begin_date`).

Однако, для поиска всех собственников объекта (разные контрагенты могут владеть разными частями объекта) только
информации о дате начала действия документа недостаточно.

### Пример

Рассмотрим таблицу переходов собственности
<table>
    <thead>
        <tr>
            <th rowspan="2">Часть собствнности</th>
            <th colspan="4">Дата перехода собственности</th>
        </tr>
        <tr> 
            <th>2023-01-01</th>    
            <th>2023-02-01</th>    
            <th>2023-03-01</th>    
            <th>2020-04-01</th>  
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1 / 2 квартиры </td>
            <td> Андрей </td>
            <td> Петя </td>
            <td> </td>
            <td> </td>
        </tr>
        <tr>
            <td>1 / 2 квартиры </td>
            <td> Андрей </td>
            <td>  </td>
            <td> Вася </td>
            <td> Семен </td>
        </tr>
    </tbody>
</table>

Дата получения собственности Васей больше чем дата получения другой части этой собствнности Петей. Но Вася не последний
владелец этой части собственности (она позже перешла к Семену).

Поэтому нужно:

1) либо чтобы из таблицы Подтверждение собственности (`personal_doc_property`) удалялись прошлые владельцы
   собственности (т.е. хранились только текущие);
2) либо документ (из `personal_doc`), который связан с подтверждением права собственности (`personal_doc_property`),
   получал дату окончания.

Далее будем считать, что выполняется именно второй пункт.

Но тогда еще остаются следующие вопросы:

1) Какая будет стоять дата окончания документа о подтверждении собственности, если человек умер?
2) Может ли человек прописаться на объекте, если все собственники мертвы?

Примем следующие ответы:

1) Дата окончания документа появится тогда, когда:
   - либо вступ в силу новый документ о подтверждении собственности
   - либо объект будет снесен
   - либо когда кто-то еще ее добавит:)
2) Будем считать, что можно прописаться, если все собственники мертвы.

------------------------------------
Найдем для каждого подтверждения собственности связанный с ним персональный документ и добавим информацию об агенте, на
которого подтверждающий документ оформлен.

<p style="color: orange">
Про прошлое решение писали "...прошу внимательно рассмотреть реализацию правильной идеи «персональном документе 
(personal_doc), который связан с записью в таблице «personal_doc_property», тут сейчас очень грубая ошибка".
</p>

Наверно, имелось в виду, что первичные ключи в таблицах `personal_doc` и `personal_doc_property` составные.


```roomsql
WITH object_doc AS (
    SELECT
       personal_doc_property.id_object, 
       personal_doc_property.id_personal_doc, 
       personal_doc.begin_date,
       personal_doc.end_date,
       personal_doc_property.id_agent,
       agent.death_date
    FROM personal_doc_property
    JOIN personal_doc ON 
        personal_doc.id_personal_doc = personal_doc_property.id_personal_doc AND
        personal_doc.id_agent = personal_doc_property.id_agent
    JOIN agent ON agent.id_agent = personal_doc_property.id_agent
)
```

Теперь в этой таблице нужно выбрать те объекты, у которых:
1) все документы имеют дату окончания не `NULL` (никто не владеет)
   ```roomsql
   WITH open_docs_object AS (
       SELECT
           object_doc.id_object,
           COUNT(*) - COUNT(object_doc.end_date) as nulls_count
       FROM object_doc
       GROUP BY
           object_doc.id_object
   ),  open_object AS (
       SELECT open_docs_object.id_object
       FROM open_docs_object
       WHERE open_docs_object.nulls_count = 0
   ), death_open_object AS (
       SELECT
           object_doc.*,
           FIRST_VALUE(death_date) OVER (
               PARTITION BY id_object
               ORDER BY id_object, death_date DESC NULLS FIRST
           ) AS last_death_date
       FROM object_doc
       WHERE
           id_object IN (SELECT * FROM open_object) AND 
           begin_date < death_date AND death_date < end_date
   )
   ```
2) есть документы, который не имеют дату окончания, но все собственники мертвы
```roomsql
WITH  last_death_object AS (
	SELECT
  		object_doc.*,
  		FIRST_VALUE(death_date) OVER (
            PARTITION BY id_object
            ORDER BY id_object, death_date DESC NULLS FIRST
        ) AS last_death_date
  	FROM object_doc
  	WHERE end_date IS NULL
)
```

Соединим таблицы
```roomsql
WITH free_object AS (
   SELECT * FROM last_death_object WHERE last_death_object.last_death_date IS NOT NULL
   UNION ALL
   SELECT * FROM death_open_object
)
```

По условию нужно взять где "... умер последний собственник более указанного количества месяцев".
Добавим в запрос выбор по дате (2 месяца назад от сегодняшней даты)" и получим

```roomsql
SELECT *
FROM free_object
WHERE last_death_date < DATE(NOW()) - INTERVAL '2 MONTH'
```

Разберемся со следующей частью задачи: "... на момент смерти последнего собственника не было ни одного живого
зарегистрированного (`id_residence_type=1`)". Звучит так, словно другие `id_residence_type` нас просто не интересуют,
поэтому будем искать только с `id_residence_type=1`.

```roomsql
WITH full_residence AS (
	SELECT
	    residence.id_object, residence.id_agent,
	    residence.id_residence_type, residence.begin_date,
	    residence.end_date, agent.death_date
  	FROM residence
  	JOIN agent ON agent.id_agent = residence.id_agent
  	WHERE residence.id_residence_type = 1
)
```

Очень странно звучит "...на момент смерти не было ...". Значит могло появиться после, но такие выбирать не надо...
Ну тогда, чтобы получить ответ, нужно выбрать только те объекты, для которых в `full_residence` нет ни одной записи
удовлетворяющей условию `дата_прописки < дата_смерти_собственника < min(дата_смерти, дата_выписки)` , причем в
`min(дата_смерти, дата_выписки)` считать что `NULL` больше любой даты.


```roomsql
SELECT *
FROM (
  SELECT
      id_object, last_death_date
  FROM free_object
  WHERE
      last_death_date < DATE(NOW()) - INTERVAL '2 MONTH'
  GROUP BY
      id_object, last_death_date
) as empty_objects
WHERE (
    SELECT COUNT(*)
    FROM full_residence
    WHERE
        empty_objects.id_object = full_residence.id_object AND
        full_residence.begin_date < empty_objects.last_death_date AND 
        empty_objects.last_death_date < CASE 
  			WHEN full_residence.death_date IS NULL AND full_residence.end_date IS NULL 
  			    THEN DATE(NOW()) 
  			WHEN full_residence.death_date < full_residence.end_date 
  			    THEN full_residence.death_date 
  			ELSE 
  			    full_residence.end_date
  	    END
) = 0
```
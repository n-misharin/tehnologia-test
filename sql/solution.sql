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
), open_docs_object AS (
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
   ), last_death_object AS (
	SELECT
  		object_doc.*,
  		FIRST_VALUE(death_date) OVER (
            PARTITION BY id_object
            ORDER BY id_object, death_date DESC NULLS FIRST
        ) AS last_death_date
  	FROM object_doc
  	WHERE end_date IS NULL
), free_object AS (
    SELECT * FROM last_death_object
    WHERE last_death_object.last_death_date IS NOT NULL
    UNION ALL
    SELECT * FROM death_open_object
), full_residence AS (
	SELECT
	    residence.id_object, residence.id_agent,
	    residence.id_residence_type, residence.begin_date,
	    residence.end_date, agent.death_date
  	FROM residence
  	JOIN agent ON agent.id_agent = residence.id_agent
  	WHERE residence.id_residence_type = 1
)
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
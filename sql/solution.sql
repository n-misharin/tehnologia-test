WITH object_last_death AS (
    SELECT
        pdp.id_object,
        pdp.id_agent,
        FIRST_VALUE(agent.death_date) OVER (
            PARTITION BY pdp.id_object
            ORDER BY pdp.id_object, agent.death_date DESC NULLS FIRST
        ) AS last_death_date,
        agent.death_date
    FROM
        personal_doc_property AS pdp
    JOIN
        personal_doc AS pd ON pd.id_personal_doc = pdp.id_personal_doc
    JOIN
        agent ON agent.id_agent = pdp.id_agent
    WHERE
        pd.end_date IS NULL
),

full_residence AS (
	SELECT
	    residence.id_object, residence.id_agent,
	    residence.id_residence_type, residence.begin_date,
	    residence.end_date, agent.death_date
  	FROM
  	    residence
  	JOIN
  	    agent ON agent.id_agent = residence.id_agent
  	WHERE
  	    residence.id_residence_type = 1
)

-- Результат
SELECT
    empty_objects.id_object
FROM (
    SELECT DISTINCT
         object_last_death.id_object,
         object_last_death.last_death_date
    FROM
         object_last_death
    WHERE
         object_last_death.last_death_date IS NOT NULL
         AND object_last_death.last_death_date < DATE(NOW()) - INTERVAL '2 MONTH'
) as empty_objects
WHERE (
    SELECT
        COUNT(*)
    FROM
        full_residence
    WHERE
       empty_objects.id_object = full_residence.id_object AND
       full_residence.begin_date < empty_objects.last_death_date AND (
           empty_objects.last_death_date < full_residence.end_date OR
           empty_objects.last_death_date < full_residence.death_date OR
           full_residence.death_date IS NULL AND full_residence.end_date IS NULL
       )
) = 0
--DROP TABLE agent_natural, agent, object, personal_doc_general, personal_doc_property, personal_doc, residence, residence_type;

CREATE TABLE IF NOT EXISTS agent (
    id_agent SERIAL PRIMARY KEY,
    agent_full_name VARCHAR(200),
    birthday_date DATE,
    death_date  DATE,
    inn INT,
    inn_kpp INT,
    ADR VARCHAR(400),
    okpo INT,
    OFK_NOMER INT,
    finance_situation_date DATE,
    id_finance_situation INT,
    id_agent_class INT,
    id_active_activity INT,
    note VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS personal_doc (
    id_personal_doc SERIAL PRIMARY KEY,
    id_agent INT,
    id_personal_doc_type  INT,
    emission_date  DATE,
    begin_date DATE,
    end_date DATE,
    id_personal_doc_class  INT,
    FOREIGN KEY (id_agent) REFERENCES agent (id_agent)
);

CREATE TABLE IF NOT EXISTS personal_doc_general(
    id SERIAL PRIMARY KEY,
    id_personal_doc INT,
    id_agent INT,
    FOREIGN KEY (id_agent) REFERENCES agent (id_agent),
    FOREIGN KEY (id_personal_doc) REFERENCES personal_doc (id_personal_doc)
);

CREATE TABLE IF NOT EXISTS agent_natural (
  id SERIAL PRIMARY KEY,
  id_agent INT,
  family VARCHAR(50) NOT NULL,
  name VARCHAR(50) NOT NULL,
  sname VARCHAR(50),
  individual_bisinessman_doc INT,
  id_sex INT,
  id_birth_place_territory INT,
  FOREIGN KEY (id_agent) REFERENCES agent (id_agent)
);

CREATE TABLE IF NOT EXISTS residence_type (
    id_residence_type SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS personal_doc_property(
    id SERIAL PRIMARY KEY,
    id_agent INT,
    id_personal_doc INT,
    id_object INT,
    property_part_dividend INT,
    property_part_divisor INT,
    right_type INT,
    FOREIGN KEY (id_agent) REFERENCES agent (id_agent),
    FOREIGN KEY (id_personal_doc) REFERENCES personal_doc (id_personal_doc)
);

CREATE TABLE IF NOT EXISTS object (
    id_object SERIAL PRIMARY KEY,
    id_territory INT,
    object_name VARCHAR(50),
    is_private BOOLEAN,
    is_drop BOOLEAN
);

CREATE TABLE IF NOT EXISTS residence (
    id SERIAL PRIMARY KEY,
    id_object INT,
    id_residence_type INT,
    begin_date  DATE,
    id_agent INT,
    id_personal_doc INT,
    end_date  DATE,
    FOREIGN KEY (id_residence_type) REFERENCES residence_type (id_residence_type),
    FOREIGN KEY (id_object) REFERENCES object (id_object),
    FOREIGN KEY (id_agent) REFERENCES agent (id_agent),
    FOREIGN KEY (id_personal_doc) REFERENCES personal_doc (id_personal_doc)
);

---add agents
INSERT INTO agent (agent_full_name)
VALUES
    ('nikita1'), ('nikita2'), ('nikita3'), ('nikita4'), ('nikita5'),
    ('nikita6'), ('nikita7'), ('nikita8'), ('nikita9'), ('nikita0');

UPDATE agent SET death_date = '2023-05-01' WHERE agent.id_agent = 1;
UPDATE agent SET death_date = '2023-06-01' WHERE agent.id_agent = 6;
UPDATE agent SET death_date = '2023-07-01' WHERE agent.id_agent = 7;
UPDATE agent SET death_date = '2023-07-01' WHERE agent.id_agent = 4;

INSERT INTO residence_type (name)
VALUES ('зарегистрирован'), ('жив, цел, орел');

INSERT INTO personal_doc (id_agent, begin_date, end_date)
VALUES
    (1, '2020-01-01', '2023-02-01'),
    (2, '2023-02-01', NULL),
    (1, '2023-03-01', NULL),
    (3, '2023-01-01', '2023-02-01') ,
    (4, '2023-02-01', NULL),
    (5, '2023-02-01', '2023-03-01'),
    (6, '2023-03-01', NULL),
    (6, '2023-01-01', '2023-02-01'),
    (7, '2023-02-01', '2023-03-01'),
    (1, '2023-02-01', '2023-03-01'),
    (5, '2023-03-01', NULL)
;
INSERT INTO object (object_name)
VALUES ('хата1'), ('хата2'), ('хата3'), ('хата4');

INSERT INTO personal_doc_property (id_agent, id_object, id_personal_doc, property_part_dividend, property_part_divisor)
VALUES
    (1, 1, 1, 1, 1),
    (2, 1, 2, 1, 1),
    (1, 3, 3, 1, 1),
    (3, 2, 4, 1, 1),
    (4, 2, 5, 1, 2),
    (5, 2, 6, 1, 2),
    (6, 2, 7, 1, 2),
    (6, 4, 8, 1, 1),
    (7, 4, 9, 1, 2),
    (1, 4, 10, 1, 2),
    (5, 4, 11, 1, 1)
;

-- Прописка
INSERT INTO residence (id_object, id_residence_type, begin_date, id_agent, end_date)
VALUES
    (1, 1, '2023-01-01', 2, NULL),
    (2, 1, '2023-01-01', 4, NULL),
    (2, 1, '2023-01-01', 6, '2023-03-01'),
    (3, 1, '2023-01-01', 1, NULL),
    (4, 1, '2023-01-01', 5, NULL),
    (3, 1, '2023-03-01', 7, NULL),
    (3, 1, '2023-03-01', 3, NULL)
;

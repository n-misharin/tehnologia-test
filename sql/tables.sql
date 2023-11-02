DROP TABLE agent_natural, agent, object, personal_doc_general, personal_doc_property, personal_doc, residence, residence_type;

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
    note VARCHAR(100),
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
    ('nikita6'), ('nikita7'), ('nikita8'), ('nikita9'), ('nikita10');


INSERT INTO residence_type (name)
VALUES ('зарегистрирован'), ('жив, цел, орел');

INSERT INTO personal_doc (id_agent, begin_date, end_date, note)
VALUES
    (1, '2000-01-01', '2023-02-01', 'паспорт'), -- 1
    (2, '2000-01-02', '2023-02-01', 'паспорт'), -- 2
    (3, '2000-01-03', '2023-02-01', 'паспорт'),
    (4, '2000-01-04', '2023-02-01', 'паспорт'),
    (5, '2000-01-05', '2023-02-01', 'паспорт'),
    (6, '2000-01-06', '2023-02-01', 'паспорт'),
    (7, '2000-01-07', '2023-02-01', 'паспорт'),
    (8, '2000-01-08', '2023-02-01', 'паспорт'),
    (9, '2000-01-09', '2023-02-01', 'паспорт'),
    (10, '2000-01-10', '2023-02-01', 'паспорт'), -- 10
    (1, '2023-01-01', NULL, 'купил хата1'),  --11
    (2, '2023-01-01', '2023-02-01', 'купил хата2'), -- 12
    (3, '2023-02-01', NULL, 'купил хата2'), -- 13
    (4, '2023-03-01', '2023-04-01', 'купил хата3'), -- 14
    (4, '2023-04-01', '2023-04-01', 'взял часть хата3'), -- 15
    (5, '2023-04-01', NULL, 'взял часть хата3'), -- 16
    (6, '2023-05-01', NULL, 'купил часть хата3'), -- 17
    (1, '2023-01-01', '2023-02-01', 'хата4'), -- 18
    (4, '2023-02-01', '2023-02-01', 'купил часть хата4'), -- 19
    (3, '2023-02-01', '2023-02-01', 'купил часть хата4'), -- 20
    (3, '2023-03-01', NULL, 'объединил хата4'), -- 21
;


INSERT INTO object (object_name)
VALUES ('хата1'), ('хата2'), ('хата3'), ('хата4'), ('хата5'), ('хата6');

INSERT INTO personal_doc_property (id_agent, id_object, id_personal_doc, property_part_dividend, property_part_divisor)
VALUES
-- агент, объект, документ, часть, часть
    (1, 1, 11, 1, 1),
    (2, 2, 12, 1, 1),
    (3, 2, 13, 1, 1),
    (4, 3, 14, 1, 1),
    (5, 3, 16, 1, 2),
    (4, 3, 15, 1, 2),
    (6, 3, 17, 1, 2),
    (1, 4, 18, 1, 1),
    (3, 4, 19, 1, 2),
    (4, 4, 20, 1, 2),
    (3, 4, 21, 1, 1),
;

-- Прописка
INSERT INTO residence (id_object, id_residence_type, begin_date, id_agent, end_date)
VALUES
    (1, 1, '2023-01-01', 2, NULL)
;

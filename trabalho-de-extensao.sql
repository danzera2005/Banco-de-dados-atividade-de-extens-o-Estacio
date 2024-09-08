CREATE TABLE aluno (
	id serial NOT NULL UNIQUE,
	firstName VARCHAR(255),
	lastName VARCHAR(255),
	cpf VARCHAR(11),
	CONSTRAINT chavealuno PRIMARY KEY (cpf)
)

CREATE TABLE responsavel (
	id serial NOT NULL UNIQUE,
	firstName VARCHAR(255) NOT NULL,
	lastName VARCHAR(255) NOT NULL,
	cpf VARCHAR(11) NOT NULL,
	firstContact VARCHAR(50) NOT NULL,
	secondContact VARCHAR(50),
	CONSTRAINT CHAVERESPONSAVEL PRIMARY KEY (cpf)
)

CREATE TABLE aluno_responsavel (
	id_aluno INTEGER NOT NULL,
	id_responsavel INTEGER NOT NULL,
	PRIMARY KEY (id_aluno, id_responsavel),
	FOREIGN KEY (id_aluno) REFERENCES aluno (id),
	FOREIGN KEY (id_responsavel) REFERENCES responsavel (id)
)

CREATE TABLE professor (
	id serial NOT NULL UNIQUE,
	firstName VARCHAR(255) NOT NULL,
	lastName VARCHAR(255) NOT NULL,
	cpf VARCHAR(255) NOT NULL,
	PRIMARY KEY (id)
)

CREATE TABLE materias (
	id serial NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL,
	carga_horaria BIGINT NOT NULL,
	limite_faltas INTEGER,
	PRIMARY KEY (id)
)

CREATE TABLE professor_materia(
	id_professor INTEGER NOT NULL,
	id_materia INTEGER NOT NULL,
	PRIMARY KEY (id_professor, id_materia),
	FOREIGN KEY (id_professor) REFERENCES professor (id),
	FOREIGN KEY (id_materia) REFERENCES materias (id)
)

CREATE TABLE turma (
	id serial NOT NULL,
	quantidade_alunos INTEGER NOT NULL,
	PRIMARY KEY (id)
)

CREATE TABLE turma_aluno (
	id_aluno INTEGER NOT NULL,
	id_turma INTEGER NOT NULL,
	PRIMARY KEY (id_aluno, id_turma),
	FOREIGN KEY (id_aluno) REFERENCES aluno (id),
	FOREIGN KEY (id_turma) REFERENCES turma (id)
)

CREATE TABLE chamada (
	id serial NOT NULL,
    id_professor INTEGER NOT NULL,
    id_turma INTEGER NOT NULL,
    id_aluno INTEGER NOT NULL,
	id_materia INTEGER NOT NULL,
    presenca BOOLEAN NOT NULL,
    data DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id),
    FOREIGN KEY (id_professor) REFERENCES professor (id),
    FOREIGN KEY (id_turma) REFERENCES turma (id),
    FOREIGN KEY (id_aluno) REFERENCES aluno (id),
    FOREIGN KEY (id_materia) REFERENCES materias (id)
)

CREATE TABLE alertas_faltas (
    id SERIAL PRIMARY KEY,
    id_aluno INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    faltas INTEGER NOT NULL,
    limite_faltas INTEGER NOT NULL,
    data_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensagem TEXT,
    FOREIGN KEY (id_aluno) REFERENCES aluno (id),
    FOREIGN KEY (id_materia) REFERENCES materias (id)
)

CREATE OR REPLACE FUNCTION verificar_faltas() 
RETURNS TRIGGER AS $$
DECLARE
    total_faltas INTEGER;
    v_limite_faltas INTEGER;
BEGIN
 
    SELECT COUNT(*) INTO total_faltas
    FROM chamada
    WHERE id_aluno = NEW.id_aluno
      AND id_materia = NEW.id_materia
      AND presenca = FALSE;

    SELECT m.limite_faltas INTO v_limite_faltas
    FROM materias m
    WHERE m.id = NEW.id_materia;

    IF total_faltas > v_limite_faltas THEN
	
        INSERT INTO alertas_faltas (id_aluno, id_materia, faltas, limite_faltas, mensagem)
        VALUES (
            NEW.id_aluno, 
            NEW.id_materia, 
            total_faltas, 
            v_limite_faltas, 
            'O aluno excedeu o limite de faltas permitido para a matéria.'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_faltas
AFTER INSERT ON chamada
FOR EACH ROW
EXECUTE FUNCTION verificar_faltas();

INSERT INTO chamada (id_professor, id_turma, id_aluno, id_materia, presenca) VALUES (1, 1, 1, 3, false)

INSERT INTO professor_materia (id_professor, id_materia) VALUES (1,2)

INSERT INTO aluno (firstname, lastname, cpf) VALUES ('Tiago','Silva','36812222222')

INSERT INTO turma (quantidade_alunos) VALUES (40)

INSERT INTO professor (firstname, lastname, cpf) VALUES ('Joseane','Silva','37827397293')

INSERT INTO materias (nome, carga_horaria, limite_faltas) VALUES ('Biologia','180','3')

INSERT INTO responsavel (firstname, lastname, cpf, firstContact, secondContact) VALUES ('Joseane','abgail','82071861515','71981811421','josydanilo@gmail.com')

INSERT INTO aluno_responsavel (id_aluno, id_responsavel) VALUES (2,1)

SELECT* FROM responsavel

SELECT * FROM alertas_faltas

SELECT* FROM aluno_responsavel

SELECT* FROM aluno

SELECT* FROM materias

SELECT* FROM turma_aluno

INSERT INTO turma_aluno (id_aluno, id_turma) VALUES (2, 1)
	
SELECT* FROM chamada

SELECT* FROM professor_materia



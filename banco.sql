REATE OR REPLACE PROCEDURE excluir_aluno(p_id_aluno IN NUMBER) AS
BEGIN
    DELETE FROM matricula WHERE id_aluno = p_id_aluno;
    DELETE FROM aluno WHERE id_aluno = p_id_aluno;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir aluno: ' || SQLERRM);
END;

DECLARE
    CURSOR alunos_maiores_18 IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(SYSDATE) - data_nascimento > 18 * 365;
    v_nome aluno.nome%TYPE;
    v_data_nascimento aluno.data_nascimento%TYPE;
BEGIN
    OPEN alunos_maiores_18;
    LOOP
        FETCH alunos_maiores_18 INTO v_nome, v_data_nascimento;
        EXIT WHEN alunos_maiores_18%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nome: ' || v_nome || ', Data de Nascimento: ' || TO_CHAR(v_data_nascimento, 'DD-MM-YYYY'));
    END LOOP;
    CLOSE alunos_maiores_18;
END;

DECLARE
    CURSOR alunos_por_curso(p_id_curso NUMBER) IS
        SELECT DISTINCT a.nome AS nome_aluno
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_id_curso;
    v_nome_aluno aluno.nome%TYPE;
BEGIN
    FOR aluno_rec IN alunos_por_curso(1)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Nome do aluno: ' || aluno_rec.nome_aluno);
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE cadastrar_disciplina(
    p_nome IN VARCHAR2,
    p_descricao IN CLOB,
    p_carga_horaria IN NUMBER
) AS
BEGIN
    INSERT INTO disciplina (nome, descricao, carga_horaria)
    VALUES (p_nome, p_descricao, p_carga_horaria);
    DBMS_OUTPUT.PUT_LINE('Disciplina cadastrada com sucesso: ' || p_nome);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro ao cadastrar disciplina: ' || SQLERRM);
END;

DECLARE
    CURSOR total_alunos_por_disciplina IS
        SELECT d.nome AS nome_disciplina, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.id_disciplina, d.nome
        HAVING COUNT(m.id_aluno) > 10;
    v_nome_disciplina disciplina.nome%TYPE;
    v_total_alunos NUMBER;
BEGIN
    OPEN total_alunos_por_disciplina;
    LOOP
        FETCH total_alunos_por_disciplina INTO v_nome_disciplina, v_total_alunos;
        EXIT WHEN total_alunos_por_disciplina%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Disciplina: ' || v_nome_disciplina || ' - Total de Alunos: ' || v_total_alunos);
    END LOOP;
    CLOSE total_alunos_por_disciplina;
END;

DECLARE
   p_id_disciplina NUMBER := 2;

   CURSOR alunos_matriculados(p_id_disciplina IN NUMBER) IS
        SELECT a.data_nascimento
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;

   v_data_nascimento aluno.data_nascimento%TYPE;
   v_media_idade NUMBER(5,2);
   v_total_alunos NUMBER := 0;
   v_soma_idades NUMBER := 0;
BEGIN
    v_soma_idades := 0;
    v_total_alunos := 0;

    OPEN alunos_matriculados(p_id_disciplina);

    LOOP
        FETCH alunos_matriculados INTO v_data_nascimento;

        EXIT WHEN alunos_matriculados%NOTFOUND;

        v_soma_idades := v_soma_idades + FLOOR(MONTHS_BETWEEN(SYSDATE, v_data_nascimento) / 12);
        v_total_alunos := v_total_alunos + 1;
    END LOOP;

    IF v_total_alunos > 0 THEN
        v_media_idade := v_soma_idades / v_total_alunos;
        DBMS_OUTPUT.PUT_LINE('Média de idade dos alunos matriculados na disciplina ' || p_id_disciplina || ' : ' || v_media_idade);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhum aluno matriculado na disciplina ' || p_id_disciplina);
    END IF;

    CLOSE alunos_matriculados;
END;

CREATE OR REPLACE PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER) IS
   v_nome_aluno aluno.nome%TYPE;
BEGIN
   FOR aluno_record IN (
      SELECT a.nome
      FROM aluno a
      JOIN matricula m ON a.id_aluno = m.id_aluno
      WHERE m.id_disciplina = p_id_disciplina AND m.status = 'Ativo'
   )
   LOOP
      DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno_record.nome);
   END LOOP;

   IF SQL%ROWCOUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Nenhum aluno matriculado na disciplina ' || p_id_disciplina);
   END IF;
END listar_alunos_disciplina;

DECLARE
    CURSOR professores_com_turmas IS
        SELECT p.nome, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.id_professor, p.nome
        HAVING COUNT(t.id_turma) > 1;

    v_nome_professor professor.nome%TYPE;
    v_total_turmas NUMBER;

BEGIN
    OPEN professores_com_turmas;

    LOOP
        FETCH professores_com_turmas INTO v_nome_professor, v_total_turmas;
        EXIT WHEN professores_com_turmas%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Professor: ' || v_nome_professor || ' - Total de turmas: ' || v_total_turmas);
    END LOOP;

    CLOSE professores_com_turmas;
END;

CREATE OR REPLACE FUNCTION total_turmas_professor(p_id_professor IN NUMBER)
   RETURN NUMBER
IS
   v_total_turmas NUMBER := 0;
BEGIN
   SELECT COUNT(*)
   INTO v_total_turmas
   FROM turma
   WHERE id_professor = p_id_professor;

   RETURN v_total_turmas;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Erro ao calcular o total de turmas: ' || SQLERRM);
END total_turmas_professor;

CREATE OR REPLACE FUNCTION obter_professor_disciplina(p_id_disciplina IN NUMBER)
   RETURN VARCHAR2
IS
   v_nome_professor professor.nome%TYPE;
BEGIN
   SELECT p.nome
   INTO v_nome_professor
   FROM professor p
   JOIN turma t ON p.id_professor = t.id_professor
   WHERE t.id_disciplina = p_id_disciplina;

   RETURN v_nome_professor;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'Nenhum professor encontrado para a disciplina informada.';
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, 'Erro ao buscar o professor: ' || SQLERRM);
END obter_professor_disciplina;
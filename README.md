# Packages
Pacotes PL/SQL para operações de aluno, disciplina e professor

# Script de Banco de Dados Oracle

Este repositório contém um script SQL completo para a criação e manipulação de dados de um sistema acadêmico. Ele inclui tabelas para alunos, disciplinas, cursos, matrículas, professores e turmas, além de pacotes (procedimentos, funções e cursores) para operações como cadastro, exclusão e consultas.

## Como Executar

1. Abra o Oracle SQL Developer ou outra ferramenta de sua escolha para executar o script.
2. Crie uma nova conexão com seu banco de dados Oracle.
3. Carregue o arquivo `script.sql`.
4. Execute o script para criar as tabelas e pacotes, e preencher as tabelas com dados de teste.

## Descrição dos Pacotes

1. **PKG_ALUNO**: Contém funções e procedimentos para gerenciar alunos, como a exclusão de alunos e listagem dos alunos maiores de 18 anos.
2. **PKG_DISCIPLINA**: Permite o cadastro de disciplinas, cálculo da média de idade dos alunos por disciplina, e listagem de alunos matriculados em uma disciplina.
3. **PKG_PROFESSOR**: Contém funções para listar professores e turmas e obter o número de turmas em que um professor leciona.

## Exemplo de Execução

O script inclui um trecho para testar os pacotes com a exclusão de alunos e a listagem de alunos e professores.


create table alunos (
	id serial primary key,
	nome varchar(100) not null,
	email varchar(100) unique not null,
	cpf varchar(11) unique not null,
	telefone varchar(50) not null,
	data_cadastro timestamp default current_timestamp
);

create table planos (
	id serial primary key,
	nome varchar(100) unique not null,
	valor_mensal_base decimal not null check (valor_mensal_base > 0)
);

create table modalidades (
	id serial primary key,
	plano_id int references planos(id),
	nome varchar(100) not null,
	sala varchar(100) not null,
	capacidade_maxima int not null check(capacidade_maxima > 0),
	disponivel bool default true
);

create table matriculas (
	id serial primary key,
	aluno_id int references alunos(id),
	data_inicio timestamp default current_timestamp,
	status varchar(30) check(status in('Ativa', 'Cancelada', 'Trancada')) default 'Ativa'
);

create table itens_matricula (
	id serial primary key,
	matricula_id int references matriculas(id),
	modalidade_id int references modalidades(id),
	duracao_meses int not null check (duracao_meses > 0),
	valor_mensal_aplicado decimal not null check (valor_mensal_aplicado > 0.00),
	taxa_adesao decimal check (taxa_adesao >= 0) default 0.00
);

--Inserção de Dados

insert into alunos(nome, email, cpf, telefone) values
('Tung Tung Sahur', '3tsahur@gmail.com', '92837567421', '(48)99674-2345'),
('Tralalero Tralala', 'tubaraodetenis@gmail.com', '05423945821', '(67)89415-3076'),
('Bailarina capuccina', 'bailarinaofc@gmail.com', '74659283754', '(42)98475-8463');

insert into planos(nome, valor_mensal_base) values
('VIP', 670.00),
('Básico', 420.00),
('MVP++', 910.00);

insert into modalidades(plano_id, nome, sala, capacidade_maxima, disponivel) values
(1, 'Boxe', 'Ringue 67', 5, false),
(2, 'Musculação', 'Studio 42', 26, true),
(3, 'Balé', 'Ringue 67', 10, true);

insert into matriculas(aluno_id, status) values
(1, 'Ativa'),
(2, 'Trancada'),
(2, 'Cancelada'),
(3, 'Ativa');

insert into itens_matricula(matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) values
(1, 1, 8, 670.00, 42.67),
(3, 1, 8, 670.00, 91.02),
(2, 2, 12, 420.00, 61.44),
(4, 3, 10, 670.00, 53.67);

--Views e Consultas Avançadas

--Q1
create view vw_modalidades_custo_estimado as
select
moda.nome as modalidade,
moda.sala,
pla.nome as plano,
(pla.valor_mensal_base + (pla.valor_mensal_base * 0.10)) as valor_pago
from modalidades moda
inner join planos pla on pla.id = moda.plano_id
order by valor_pago desc;
--Q1

--Q2
create view vw_matriculas_ativas as
select
alu.nome as nome_aluno,
alu.cpf,
moda.nome as modalidade,
moda.sala,
itn.duracao_meses as duracao_contrato,
mat.data_inicio
from alunos alu
inner join matriculas mat on mat.aluno_id = alu.id
inner join itens_matricula itn on itn.matricula_id = mat.id
inner join modalidades moda on moda.id = itn.modalidade_id
where mat.status = 'Ativa';
--Q2

--Pulei a Q3 pq ela ta tudo bugada no teu repositório willer

--Q4
select
moda.nome as nome_modalidade,
moda.sala,
moda.capacidade_maxima,
moda.disponivel,
pla.valor_mensal_base
from modalidades moda
inner join planos pla on moda.plano_id = pla.id
where pla.valor_mensal_base > 100.00
and moda.capacidade_maxima >= 15
and moda.disponivel = true;
--Q4

--Q5
create view vw_faturamento_medio_plano as
select
pla.nome as nome_plano,
sum(itn.valor_mensal_aplicado * itn.duracao_meses) as faturamento_medio,
avg(itn.duracao_meses) as media_duracao_meses
from planos pla
inner join modalidades moda on moda.plano_id = pla.id
inner join itens_matricula itn on itn.modalidade_id = moda.id
inner join matriculas mat on mat.id = itn.matricula_id
where mat.status = 'Ativa'
group by pla.nome;
--Q5
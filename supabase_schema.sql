-- ============================================================
-- Painel Financeiro CFO Edition · Setup do Supabase
-- Execute este script no Supabase Dashboard > SQL Editor
-- ============================================================

-- Tabela de estado do usuário (uma linha por usuário, contém todo o
-- estado do app em JSONB). O isolamento é garantido pelo RLS abaixo.
create table if not exists public.user_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Ativa a segurança em nível de linha (Row Level Security)
alter table public.user_state enable row level security;

-- Políticas: cada usuário só pode acessar a PRÓPRIA linha.
-- O uid é derivado do token de autenticação (nunca confiado no cliente).
create policy "user_state_select_own"
  on public.user_state for select
  using (auth.uid() = user_id);

create policy "user_state_insert_own"
  on public.user_state for insert
  with check (auth.uid() = user_id);

create policy "user_state_update_own"
  on public.user_state for update
  using (auth.uid() = user_id);

create policy "user_state_delete_own"
  on public.user_state for delete
  using (auth.uid() = user_id);

-- Índice (a PK já cobre user_id, este é para updated_at em relatórios)
create index if not exists idx_user_state_updated_at
  on public.user_state (updated_at desc);

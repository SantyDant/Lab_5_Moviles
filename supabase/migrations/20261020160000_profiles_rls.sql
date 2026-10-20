-- Seguridad a nivel de fila para la tabla profiles:
-- cada usuario autenticado solo puede crear, leer y editar su propio perfil.
alter table public.profiles enable row level security;

create policy "Usuarios leen su propio perfil"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Usuarios crean su propio perfil"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Usuarios editan su propio perfil"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

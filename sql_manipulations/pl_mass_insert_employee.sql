create or replace function z_mass_insert_employee()
returns setof void as $$
declare
begin
  for i in 1..1000000 loop
    perform * from z_insert_employee();
  end loop;
return;
end; $$ language plpgsql;

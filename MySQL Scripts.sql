drop database if exists GestorProyectos;
create database GestorProyectos;
use GestorProyectos;

-- Tabla Participante = Almacenara todos los participantes existentes en la base
-- Observacion = Un nombre mas apropiado sera Empleado *CAMBIO PENDIENTE*
create table Participante(
	id 			int primary key auto_increment,
	nombre 		varchar(40) not null,
    apellidoM	varchar(20) not null,
    apellidoP 	varchar(20) not null, 
    usuario		varchar(20) unique not null,
    cargo 		set("Participante", "Administrador de Proyecto", "Administrador General") not null
);

-- Tabla Proyecto = Almacenara todos los proyectos existentes en la base
create table Proyecto(
	id 				int primary key auto_increment,
	nombre 			varchar(40) not null,
	objetivo 		varchar(60),
    fecha_inicio	date,
    fecha_fin		date,
    descripcion		text(200),
    responsable		int,
    foreign key (responsable) references Participante(id)
);

-- Tabla Tarea = Almacenara todas los tareas existentes en la base
create table Tarea(
	id 				int primary key auto_increment,
	nombre 			varchar(40) not null,
	fecha_inicio	date,
    fecha_fin		date,
    estado			set("Pendiente", "En Proceso", "Terminada", "Cancelada"),
    prioridad		set("Baja", "Normal", "Alta", "Urgente"),
    descripcion		text(200),
    id_proyecto 	int,
    foreign key (id_proyecto) references Proyecto(id)
);

-- Tabla Tarea_Participante = Almacenara todas las asignaciones de Tarea a Participante existentes en la base
create table Tarea_Participante(
	id_tarea			int not null,
	id_participante		int not null,
    primary key (id_tarea, id_participante),
    foreign key (id_tarea) references Tarea(id),
    foreign key (id_participante) references Participante(id)
);

-- Tabla Tarea_Tarea = Almacenara todas las precedencias entre Tareas existentes en la base
create table Tarea_Tarea(
	id_tarea1	int not null,
    id_tarea2	int not null,
    primary key (id_tarea1, id_tarea2),
    foreign key (id_tarea1) references Tarea(id),
    foreign key (id_tarea2) references Tarea(id)
);

/* --------------Procesos de permisos--------------------------------------------------------------- */

delimiter //
create procedure permisos (in _usuario varchar(20), in _permiso set ('Participante','Administrador de Proyecto','Administrador General'))
begin
case 
when _permiso = 'Participante' then
grant execute on procedure participantes to _usuario@'%';
grant execute on procedure tareas to _usuario@'%';
grant execute on procedure proyectos to _usuario@'%';

when _permiso = 'Administrador de Proyecto' then
grant execute on procedure participantes to _usuario@'%';
grant execute on procedure tareas to _usuario@'%';
grant execute on procedure proyectos to _usuario@'%';
grant execute on procedure altaTarea to _usuario@'%';
grant execute on procedure asignarTarea to _usuario@'%';
grant execute on procedure asignarPrecedenciaTarea to _usuario@'%';
grant execute on procedure tareaActualizacion to _usuario@'%';
grant execute on procedure tareaBorrar to _usuario@'%';

when _permiso = 'Administrador General' then
grant execute on procedure participantes to _usuario@'%';
grant execute on procedure tareas to _usuario@'%';
grant execute on procedure proyectos to _usuario@'%';
grant execute on procedure altaParticipante to _usuario@'%';
grant execute on procedure altaTarea to _usuario@'%';
grant execute on procedure altaProyecto to _usuario@'%';
grant execute on procedure asignarTarea to _usuario@'%';
grant execute on procedure asignarPrecedenciaTarea to _usuario@'%';
grant execute on procedure tareaActualizacion to _usuario@'%';
grant execute on procedure proyectoActualizacion to _usuario@'%';
grant execute on procedure tareaBorrar to _usuario@'%';
grant execute on procedure proyectoBorrar to _usuario@'%';
end case;

end //

/* --------------Procesos de Creacion de registros--------------------------------------------------------------- */

delimiter //
create procedure altaParticipante (in _nombre varchar(40), in _apellidoP varchar(20), in _apellidoM varchar(20), in _usuario varchar(20), in _cargo set("Participante", "Administrador de Proyecto", "Administrador General"))
begin
insert into Participante (nombre, apellidoP, apellidoM, usuario, cargo) values (_nombre, _apellidoP, _apellidoM, _usuario, _cargo);
create user _usuario@'%';
call permisos(_usuario, _cargo);
end //

delimiter //
create procedure altaProyecto (in _nombre varchar(40), in _objetivo varchar(60), in _fecha_inicio date,
								in _fecha_fin date, in _descripcion text(120), in _responsable int)
begin
insert into Proyecto (nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) 
values (_nombre, _objetivo, _fecha_inicio, _fecha_fin, _descripcion, _responsable);
end //

delimiter //
create procedure altaTarea (in _nombre varchar(40), _fecha_inicio date, _fecha_fin date, 
							in _estado set("Pendiente", "En Proceso", "Terminada", "Cancelada"),
                            in _prioridad set("Baja", "Normal", "Alta", "Urgente"),
							in _descripcion text(120), _id_proyecto int)
begin
insert into Tarea (nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) 
values (_nombre, _fecha_inicio, _fecha_fin, _estado, _prioridad, _descripcion, _id_proyecto);
end //

delimiter //
create procedure asignarTarea (in _id_tarea int, in _id_participante int)
begin
insert into Tarea_Participante (id_tarea, id_participante) 
values (_id_tarea, _id_participante);
end //

delimiter //
create procedure asignarPrecedenciaTarea (in _id_tarea1 int, in _id_tarea2 int)
begin
insert into Tarea_Tarea (id_tarea1, _id_tarea2) 
values (_id_tarea1, _id_tarea2);
end //

/* --------------Procesos de Lectura de registros--------------------------------------------------------------- */

delimiter //
create procedure participantes ()
begin
declare sub json;
set sub = (select id, cargo from Participante where usuario = substring(current_user(), 1, locate('@', current_user()) - 1));
case 

when sub.cargo = "Participante" then
select p.nombre, p.apellidoP, p.apellidoM, t.id_tarea 
from participante p, tarea_participante t, (select id_tarea t from tarea_participante p where sub.id = id_participante) tr 
where p.id = t.id_participante and tr.t = t.id_tarea;

when sub.cargo = "Administrador de Proyecto" then /* cambio pendiente*/
select pr.nombre, t.nombre, p2.* from participante p 
inner join proyecto pr on p.id = pr.responsable
inner join tarea t on t.id_proyecto = pr.id
inner join tarea_participante tp on tp.id_tarea = t.id
inner join participante p2 on p2.id = tp.id_participante
where p.id = sub.id; 

when sub.cargo = "Administrador General" then
select * from participante;

end case;
end //

delimiter //
create procedure proyectos ()
begin
declare sub json;
set sub = (select id, cargo from Participante where usuario = substring(current_user(), 1, locate('@', current_user()) - 1));
case 

when sub.cargo = "Participante" then
select p.* from proyecto p
inner join tarea t on t.id_proyecto = p.id
inner join tarea_participante tp on tp.id_tarea = t.id
where tp.id_participante = sub.id;

when sub.cargo = "Administrador de Proyecto" then 
select p.* from proyecto p, participante pr
where p.responsable = pr.id 
union 
select p.* from proyecto p
inner join tarea t on t.id_proyecto = p.id
inner join tarea_participante tp on tp.id_tarea = t.id
where tp.id_participante = sub.id;


when sub.cargo = "Administrador General" then
select * from proyecto;

end case;
end //

delimiter //
create procedure tareas ()
begin
declare sub json;
set sub = (select id, cargo from Participante where usuario = substring(current_user(), 1, locate('@', current_user()) - 1));
case 

when sub.cargo = "Participante" then
select p.nombre, t.nombre, t.fecha_inicio, t.fecha_fin, t.estado, t.prioridad, t.descripcion
from tarea t inner join proyecto p on t.id_proyecto = p.id
inner join tarea_participante tp on t.id = tp.id_tarea
where tp.id_participante = sub.id;

when sub.cargo = "Administrador de Proyecto" then /* cambio pendiente*/
select * from tarea t
inner join proyecto p on t.id_proyecto = p.id
where p.responsable = sub.id;

when sub.cargo = "Administrador General" then
select * from tarea;
end case;

end //

/* --------------Procesos de actualizacion de registros--------------------------------------------------------------- */

delimiter //
create procedure proyectoActualizacion (in _id int, in _nombre varchar(40), in _objetivo varchar(60), in _fecha_inicio date,
										in _fecha_fin date, in _descripcion text(120), in _responsable int)
begin
update tarea set nombre = _nombre, objetivo = _objetivo, fecha_inicio = _fecha_inicio, fecha_fin = _fecha_fin, 
				descripcion = _descripcion, responsable = _responsable where id = _id;
end //

delimiter //
create procedure tareaActualizacion (in _id int, in _nombre varchar(40), in _fecha_inicio date, in _fecha_fin date, 
									in _estado set("Pendiente", "En Proceso", "Terminada", "Cancelada"), 
                                    in _prioridad set("Baja", "Normal", "Alta", "Urgente"), in _descripcion text(120))
begin
update tarea set nombre = _nombre, fecha_inicio = _fecha_inicio, fecha_fin = _fecha_fin, estado = _estado, 
							prioridad = _prioridad, descripcion = _descripcion where id = _id;
end //

/* --------------Procesos de borrado de registros--------------------------------------------------------------- */

delimiter //
create procedure tareaBorrar (in _id int)
begin
delete from tarea where id = _id;
end //

delimiter //
create procedure proyectoBorrar (in _id int)
begin
delete from proyecto where id = _id;
end //

insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (1, 'Rafaellle', 'Ogg', 'Eacott', 'reacott0', 'Administrador General');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (2, 'Alyce', 'Maiden', 'Manass', 'amanass1', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (3, 'Aliza', 'Gleed', 'Cortez', 'acortez2', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (4, 'Mildrid', 'Bootton', 'Wilstead', 'mwilstead3', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (5, 'Marcia', 'Spurden', 'Ogilvie', 'mogilvie4', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (6, 'Jody', 'Gloucester', 'Celloni', 'jcelloni5', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (7, 'Missie', 'Romanet', 'Stoeckle', 'mstoeckle6', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (8, 'Piper', 'Reimer', 'Stode', 'pstode7', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (9, 'Tiphany', 'Gounet', 'Charlton', 'tcharlton8', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (10, 'Trumaine', 'Proctor', 'Rowesby', 'trowesby9', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (11, 'Olly', 'Whitnell', 'Cassells', 'ocassellsa', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (12, 'Kessia', 'Sowray', 'Giblin', 'kgiblinb', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (13, 'Charlean', 'Nockells', 'Paramor', 'cparamorc', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (14, 'Abeu', 'Chislett', 'Leggate', 'aleggated', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (15, 'Nikki', 'Rickell', 'Bagworth', 'nbagworthe', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (16, 'Libbie', 'Brommage', 'Hallgath', 'lhallgathf', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (17, 'Gordan', 'Stainton - Skinn', 'Nelles', 'gnellesg', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (18, 'Nicolais', 'Millmoe', 'Amoss', 'namossh', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (19, 'Melva', 'Crackett', 'Doles', 'mdolesi', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (20, 'Freddi', 'Gadault', 'Sayse', 'fsaysej', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (21, 'Lilia', 'Daice', 'Durtnel', 'ldurtnelk', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (22, 'Juli', 'Sutherden', 'Hoffmann', 'jhoffmannl', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (23, 'Brent', 'Breache', 'Queree', 'bquereem', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (24, 'Genia', 'Neighbour', 'Bibby', 'gbibbyn', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (25, 'Tuck', 'Gilmore', 'Bosden', 'tbosdeno', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (26, 'Abigael', 'Husselbee', 'Berthon', 'aberthonp', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (27, 'Beverlie', 'Rettie', 'Viles', 'bvilesq', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (28, 'Maxine', 'Kybbye', 'Surgener', 'msurgenerr', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (29, 'Morganica', 'Fitzpayn', 'Gawke', 'mgawkes', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (30, 'Lizbeth', 'Formie', 'Skewes', 'lskewest', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (31, 'Murdock', 'Loakes', 'Kippins', 'mkippinsu', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (32, 'Erma', 'Dafydd', 'MacWilliam', 'emacwilliamv', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (33, 'Pauletta', 'Brody', 'Schwieso', 'pschwiesow', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (34, 'Kirby', 'Kirk', 'Alcock', 'kalcockx', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (35, 'Aimil', 'De Brett', 'Loudwell', 'aloudwelly', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (36, 'Reggie', 'Hinzer', 'Torbett', 'rtorbettz', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (37, 'Candice', 'Brodeur', 'Karpfen', 'ckarpfen10', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (38, 'Berny', 'Bloomfield', 'Dixey', 'bdixey11', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (39, 'Deva', 'Nicholson', 'Stanett', 'dstanett12', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (40, 'Meade', 'Santos', 'Pitrollo', 'mpitrollo13', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (41, 'Mariam', 'Josebury', 'Jukubczak', 'mjukubczak14', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (42, 'Mikey', 'Yardy', 'Haseman', 'mhaseman15', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (43, 'Correy', 'Beechcraft', 'Berndtsson', 'cberndtsson16', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (44, 'Collen', 'Learmont', 'Oakhill', 'coakhill17', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (45, 'Loise', 'Hasley', 'Danson', 'ldanson18', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (46, 'Ansel', 'McLaren', 'Conibeer', 'aconibeer19', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (47, 'Martino', 'Jeanesson', 'Cater', 'mcater1a', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (48, 'Way', 'Kleiser', 'Casolla', 'wcasolla1b', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (49, 'Anthony', 'Mussilli', 'Lesly', 'alesly1c', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (50, 'Flo', 'Odegaard', 'Robathon', 'frobathon1d', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (51, 'Kerri', 'Snoding', 'Jozsa', 'kjozsa1e', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (52, 'Inna', 'Bevington', 'Edgeley', 'iedgeley1f', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (53, 'Renae', 'Chanter', 'Goodin', 'rgoodin1g', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (54, 'Marion', 'Noulton', 'Brack', 'mbrack1h', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (55, 'Orelle', 'Gresham', 'Fitzsymonds', 'ofitzsymonds1i', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (56, 'Corrianne', 'Little', 'Bracchi', 'cbracchi1j', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (57, 'Karlene', 'Henken', 'Fawthrop', 'kfawthrop1k', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (58, 'Boothe', 'Meech', 'Raddin', 'braddin1l', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (59, 'Giralda', 'Perschke', 'Buncom', 'gbuncom1m', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (60, 'Ralina', 'Lightwing', 'Hedney', 'rhedney1n', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (61, 'Lauri', 'Tonkinson', 'Licciardo', 'llicciardo1o', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (62, 'Kenna', 'Swyre', 'Copeman', 'kcopeman1p', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (63, 'Reginauld', 'Broe', 'Ziehm', 'rziehm1q', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (64, 'Tonye', 'Lympenie', 'Polglase', 'tpolglase1r', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (65, 'Craggie', 'Braisher', 'Rootes', 'crootes1s', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (66, 'Gilemette', 'Renwick', 'Moxstead', 'gmoxstead1t', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (67, 'Brandy', 'Backshill', 'Rawlin', 'brawlin1u', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (68, 'Kathryn', 'Ballay', 'Minter', 'kminter1v', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (69, 'Ardisj', 'Chestle', 'Wragg', 'awragg1w', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (70, 'Samantha', 'Darrigoe', 'Burnie', 'sburnie1x', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (71, 'Cynthy', 'Wawer', 'Broggetti', 'cbroggetti1y', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (72, 'Layne', 'Luckes', 'Semark', 'lsemark1z', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (73, 'Jase', 'Brenston', 'Adamthwaite', 'jadamthwaite20', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (74, 'Marley', 'Ascrofte', 'Goodband', 'mgoodband21', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (75, 'Adiana', 'Surgen', 'Dewdney', 'adewdney22', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (76, 'Florence', 'Flaherty', 'Colquit', 'fcolquit23', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (77, 'Barbi', 'Dreng', 'Gantzman', 'bgantzman24', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (78, 'Corie', 'Ladbrook', 'Pavlik', 'cpavlik25', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (79, 'Giraldo', 'Mullins', 'Retallack', 'gretallack26', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (80, 'Hedy', 'Dennick', 'Jansens', 'hjansens27', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (81, 'Abigale', 'Latham', 'Toghill', 'atoghill28', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (82, 'Ottilie', 'Ethridge', 'Bengal', 'obengal29', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (83, 'Etan', 'Baldrick', 'Phonix', 'ephonix2a', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (84, 'Gabby', 'Acom', 'Baggalley', 'gbaggalley2b', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (85, 'Tracee', 'Poytres', 'Twiggs', 'ttwiggs2c', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (86, 'Myca', 'Perry', 'Esselen', 'messelen2d', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (87, 'Pascale', 'Dillintone', 'Scroggs', 'pscroggs2e', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (88, 'Glyn', 'Motion', 'Guild', 'gguild2f', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (89, 'Joyann', 'MacTeggart', 'Lonie', 'jlonie2g', 'Administrador de Proyecto');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (90, 'Kalil', 'Spradbrow', 'Chirm', 'kchirm2h', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (91, 'Efrem', 'Partleton', 'Feitosa', 'efeitosa2i', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (92, 'Son', 'Buss', 'Chazelle', 'schazelle2j', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (93, 'Dido', 'Yanin', 'Breslin', 'dbreslin2k', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (94, 'Tiler', 'Willcocks', 'Ganniclifft', 'tganniclifft2l', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (95, 'Arnie', 'Hamlington', 'Whellans', 'awhellans2m', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (96, 'Cointon', 'Valentetti', 'Walewski', 'cwalewski2n', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (97, 'Link', 'Wadman', 'Orth', 'lorth2o', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (98, 'Manolo', 'Fauning', 'Lymer', 'mlymer2p', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (99, 'Tina', 'Laird', 'Lillico', 'tlillico2q', 'Participante');
insert into Participante (id, nombre, apellidoM, apellidoP, usuario, cargo) values (100, 'Brittan', 'Alennikov', 'McAusland', 'bmcausland2r', 'Participante');

insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (1, 'Ronstring', 'adipiscing lorem vitae', '2023-05-09', '2023-11-28', null, 81);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (2, 'Voyatouch', 'non velit nec', '2023-06-13', '2024-04-01', 'aliquet maecenas leo odio condimentum id luctus nec molestie sed', 81);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (3, 'Cardguard', 'primis in faucibus', '2023-04-03', '2024-08-23', 'ut volutpat sapien arcu sed augue aliquam erat volutpat in', 45);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (4, 'Fixflex', 'nulla eget eros', '2023-09-28', '2024-03-05', 'ut blandit non interdum in ante vestibulum ante ipsum primis', 99);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (5, 'Tempsoft', 'molestie lorem quisque', '2023-04-18', '2023-11-30', 'ullamcorper purus sit amet nulla quisque arcu libero rutrum ac', 79);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (6, 'Cardguard2', 'vulputate nonummy maecenas', '2023-01-31', '2024-02-11', 'tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida', 24);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (7, 'Prodder', 'quam sollicitudin vitae', '2023-03-21', '2024-05-02', null, 39);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (8, 'Greenlam', 'vestibulum proin eu', '2023-09-01', '2024-10-30', 'sit amet nulla quisque arcu libero rutrum ac lobortis vel', 88);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (9, 'Alphazap', 'vestibulum sagittis sapien', '2023-04-22', '2024-01-08', 'ut erat curabitur gravida nisi at nibh in hac habitasse', 36);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (10, 'Tresom', 'massa id lobortis', '2022-11-17', '2024-07-16', 'dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum', 79);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (11, 'Sonair', 'vestibulum ac est', '2023-05-04', '2024-10-30', 'dapibus nulla suscipit ligula in lacus curabitur at ipsum ac', 53);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (12, 'Toughjoyfax', 'magna at nunc', '2023-02-11', '2024-01-31', 'ipsum primis in faucibus orci luctus et ultrices posuere cubilia', 33);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (13, 'Overhold', 'vulputate nonummy maecenas', '2023-06-21', '2024-01-13', 'curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor', 82);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (14, 'Tresom2', 'at nulla suspendisse', '2023-08-26', '2024-01-16', 'molestie nibh in lectus pellentesque at nulla suspendisse potenti cras', 11);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (15, 'Voyatouch2', 'sapien varius ut', '2022-12-23', '2024-10-15', 'eu mi nulla ac enim in tempor turpis nec euismod', 76);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (16, 'Lotstring', 'posuere felis sed', '2023-03-13', '2024-10-16', 'eros vestibulum ac est lacinia nisi venenatis tristique fusce congue', 55);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (17, 'Ventosanzap', 'magna ac consequat', '2022-12-07', '2023-12-02', 'habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla', 33);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (18, 'Sonair2', 'sagittis dui vel', '2022-12-24', '2024-08-23', null, 22);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (19, 'Overhold2', 'nec nisi volutpat', '2023-08-14', '2024-09-15', 'lectus in quam fringilla rhoncus mauris enim leo rhoncus sed', 63);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (20, 'Pannier', 'sed augue aliquam', '2023-11-04', '2024-04-04', 'sapien a libero nam dui proin leo odio porttitor id', 12);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (21, 'Namfix', 'ut mauris eget', '2022-11-20', '2024-09-16', 'pede malesuada in imperdiet et commodo vulputate justo in blandit', 5);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (22, 'Pannier2', 'nam nulla integer', '2023-03-06', '2024-05-28', 'in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum', 59);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (23, 'Holdlamis', 'commodo placerat praesent', '2022-12-02', '2024-06-15', 'pede posuere nonummy integer non velit donec diam neque vestibulum', 82);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (24, 'Zontrax', 'et eros vestibulum', '2023-03-11', '2023-11-28', 'nam dui proin leo odio porttitor id consequat in consequat', 18);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (25, 'Viva', 'blandit nam nulla', '2022-11-27', '2024-03-25', 'hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer', 10);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (26, 'Regrant', 'nulla dapibus dolor', '2023-03-19', '2024-09-18', 'in libero ut massa volutpat convallis morbi odio odio elementum', 80);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (27, 'Redhold', 'donec dapibus duis', '2023-02-03', '2024-06-05', 'lacus at turpis donec posuere metus vitae ipsum aliquam non', 81);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (28, 'Rank', 'enim sit amet', '2023-10-30', '2024-03-06', 'maecenas tristique est et tempus semper est quam pharetra magna', 43);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (29, 'Viva2', 'pede venenatis non', '2023-06-02', '2024-04-16', 'luctus cum sociis natoque penatibus et magnis dis parturient montes', 84);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (30, 'Stim', 'nam dui proin', '2023-09-03', '2024-08-15', 'tempus sit amet sem fusce consequat nulla nisl nunc nisl', 64);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (31, 'Sonair3', 'vestibulum ante ipsum', '2022-11-18', '2023-11-19', 'cursus vestibulum proin eu mi nulla ac enim in tempor', 51);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (32, 'Cardguard3', 'lacinia nisi venenatis', '2023-11-03', '2024-10-28', 'in hac habitasse platea dictumst morbi vestibulum velit id pretium', 33);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (33, 'Keylex', 'massa id lobortis', '2023-07-20', '2024-07-14', 'faucibus orci luctus et ultrices posuere cubilia curae duis faucibus', 25);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (34, 'Solarbreeze', 'penatibus et magnis', '2023-02-27', '2024-06-16', null, 2);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (35, 'Tampflex', 'justo pellentesque viverra', '2023-09-10', '2023-12-19', 'platea dictumst etiam faucibus cursus urna ut tellus nulla ut', 42);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (36, 'Greenlam2', 'cursus vestibulum proin', '2023-08-13', '2024-10-31', 'in leo maecenas pulvinar lobortis est phasellus sit amet erat', 36);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (37, 'Greenlam3', 'in faucibus orci', '2023-05-17', '2024-11-05', null, 75);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (38, 'Stronghold', 'ut nunc vestibulum', '2023-08-07', '2024-11-08', 'maecenas tristique est et tempus semper est quam pharetra magna', 51);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (39, 'Solarbreeze2', 'nullam molestie nibh', '2023-06-21', '2024-04-14', 'quis augue luctus tincidunt nulla mollis molestie lorem quisque ut', 18);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (40, 'Mat Lam Tam', 'nulla tempus vivamus', '2023-06-21', '2023-12-18', 'porta volutpat erat quisque erat eros viverra eget congue eget', 22);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (41, 'Redhold2', 'ut dolor morbi', '2023-03-27', '2024-09-10', 'sed tincidunt eu felis fusce posuere felis sed lacus morbi', 51);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (42, 'Sonair4', 'in imperdiet et', '2023-06-15', '2024-09-22', 'lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus', 59);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (43, 'Quo Lux', 'sed justo pellentesque', '2023-05-23', '2024-11-01', 'est quam pharetra magna ac consequat metus sapien ut nunc', 18);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (44, 'Keylex2', 'in purus eu', '2023-08-21', '2024-03-15', null, 23);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (45, 'Latlux', 'ut ultrices vel', '2023-07-14', '2024-06-01', 'ultrices aliquet maecenas leo odio condimentum id luctus nec molestie', 15);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (46, 'Rank2', 'vel accumsan tellus', '2023-09-10', '2024-01-03', 'at dolor quis odio consequat varius integer ac leo pellentesque', 9);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (47, 'Viva3', 'quam nec dui', '2023-07-29', '2023-12-07', 'in leo maecenas pulvinar lobortis est phasellus sit amet erat', 49);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (48, 'Zamit', 'justo pellentesque viverra', '2023-08-02', '2024-09-28', 'adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus', 28);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (49, 'Gembucket', 'vestibulum eget vulputate', '2023-04-04', '2024-02-10', 'volutpat dui maecenas tristique est et tempus semper est quam', 56);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (50, 'Sonsing', 'quam turpis adipiscing', '2023-04-01', '2024-06-11', 'ligula nec sem duis aliquam convallis nunc proin at turpis', 64);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (51, 'Keylex3', 'in est risus', '2023-02-04', '2024-02-03', 'metus vitae ipsum aliquam non mauris morbi non lectus aliquam', 15);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (52, 'Prodder2', 'amet justo morbi', '2023-06-06', '2024-02-25', 'eget semper rutrum nulla nunc purus phasellus in felis donec', 7);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (53, 'Wrapsafe', 'mauris lacinia sapien', '2023-05-05', '2023-11-27', 'in sagittis dui vel nisl duis ac nibh fusce lacus', 78);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (54, 'Tampflex2', 'curae duis faucibus', '2023-02-08', '2024-02-13', null, 34);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (55, 'Voyatouch3', 'felis donec semper', '2023-06-27', '2024-04-22', 'felis ut at dolor quis odio consequat varius integer ac', 68);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (56, 'Fixflex2', 'ipsum primis in', '2023-10-06', '2024-02-07', 'eu mi nulla ac enim in tempor turpis nec euismod', 47);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (57, 'Cookley', 'magnis dis parturient', '2022-11-16', '2024-07-12', 'cubilia curae nulla dapibus dolor vel est donec odio justo', 83);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (58, 'Bigtax', 'ipsum primis in', '2023-05-01', '2024-05-30', 'turpis sed ante vivamus tortor duis mattis egestas metus aenean', 44);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (59, 'Fixflex', 'potenti nullam porttitor', '2023-04-27', '2024-08-24', null, 54);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (60, 'Sonair5', 'vehicula condimentum curabitur', '2023-01-19', '2024-01-16', 'nulla justo aliquam quis turpis eget elit sodales scelerisque mauris', 78);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (61, 'Konklux', 'ligula nec sem', '2023-06-14', '2024-08-05', 'erat vestibulum sed magna at nunc commodo placerat praesent blandit', 54);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (62, 'Tempsoft', 'orci luctus et', '2023-08-29', '2024-08-30', 'risus semper porta volutpat quam pede lobortis ligula sit amet', 7);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (63, 'Lotlux', 'bibendum morbi non', '2022-12-21', '2024-04-29', 'diam erat fermentum justo nec condimentum neque sapien placerat ante', 21);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (64, 'Ronstring', 'libero non mattis', '2023-06-28', '2024-04-08', 'convallis eget eleifend luctus ultricies eu nibh quisque id justo', 3);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (65, 'Fintone', 'consequat in consequat', '2023-01-11', '2024-05-05', 'interdum mauris non ligula pellentesque ultrices phasellus id sapien in', 33);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (66, 'Stronghold', 'nibh ligula nec', '2023-07-28', '2024-03-24', 'sit amet nunc viverra dapibus nulla suscipit ligula in lacus', 88);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (67, 'Trippledex', 'consequat dui nec', '2023-06-15', '2024-02-03', 'arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus', 97);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (68, 'Tampflex', 'in faucibus orci', '2023-02-16', '2024-07-06', 'non interdum in ante vestibulum ante ipsum primis in faucibus', 36);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (69, 'Sonsing', 'nec nisi volutpat', '2023-09-10', '2024-11-07', 'ipsum ac tellus semper interdum mauris ullamcorper purus sit amet', 6);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (70, 'Subin', 'amet turpis elementum', '2023-02-10', '2024-11-09', 'habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt', 54);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (71, 'Domainer', 'ac enim in', '2023-04-21', '2024-09-19', 'mauris lacinia sapien quis libero nullam sit amet turpis elementum', 21);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (72, 'Sonair', 'interdum venenatis turpis', '2022-11-28', '2024-01-22', 'rhoncus sed vestibulum sit amet cursus id turpis integer aliquet', 45);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (73, 'Bigtax', 'venenatis turpis enim', '2023-09-22', '2024-08-01', 'ut erat id mauris vulputate elementum nullam varius nulla facilisi', 82);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (74, 'Sonsing', 'cursus id turpis', '2023-06-26', '2024-04-12', 'condimentum neque sapien placerat ante nulla justo aliquam quis turpis', 64);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (75, 'Duobam', 'eu tincidunt in', '2023-09-25', '2024-05-24', null, 97);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (76, 'Zontrax', 'volutpat erat quisque', '2023-05-07', '2023-11-22', null, 41);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (77, 'Temp', 'diam erat fermentum', '2023-03-09', '2024-09-29', 'rhoncus dui vel sem sed sagittis nam congue risus semper', 57);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (78, 'Konklab', 'in congue etiam', '2023-03-01', '2024-09-03', 'vitae nisi nam ultrices libero non mattis pulvinar nulla pede', 60);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (79, 'Lotlux', 'vestibulum ac est', '2023-02-28', '2024-09-17', 'consequat ut nulla sed accumsan felis ut at dolor quis', 3);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (80, 'Y-Solowarm', 'natoque penatibus et', '2023-08-26', '2023-12-15', 'sit amet diam in magna bibendum imperdiet nullam orci pede', 17);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (81, 'Daltfresh', 'adipiscing lorem vitae', '2022-12-29', '2023-12-12', 'accumsan felis ut at dolor quis odio consequat varius integer', 47);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (82, 'Fix San', 'ut odio cras', '2023-02-08', '2024-06-06', 'nulla suscipit ligula in lacus curabitur at ipsum ac tellus', 91);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (83, 'Lotlux', 'sapien a libero', '2023-01-28', '2024-02-21', 'tempus sit amet sem fusce consequat nulla nisl nunc nisl', 82);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (84, 'Daltfresh', 'elit proin risus', '2023-01-25', '2024-01-21', 'platea dictumst maecenas ut massa quis augue luctus tincidunt nulla', 18);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (85, 'Solarbreeze', 'ut tellus nulla', '2023-10-30', '2023-12-25', null, 84);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (86, 'Fix San', 'pellentesque ultrices phasellus', '2023-05-09', '2024-04-12', 'mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus', 75);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (87, 'Bamity', 'risus dapibus augue', '2023-03-02', '2024-05-14', 'tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida', 18);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (88, 'Konklab', 'suspendisse accumsan tortor', '2023-05-16', '2024-07-17', null, 78);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (89, 'Alphazap', 'dictumst aliquam augue', '2022-12-14', '2024-06-13', 'ac est lacinia nisi venenatis tristique fusce congue diam id', 65);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (90, 'Treeflex', 'convallis nulla neque', '2023-04-04', '2024-05-11', 'ut massa quis augue luctus tincidunt nulla mollis molestie lorem', 73);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (91, 'Home Ing', 'vestibulum quam sapien', '2023-04-30', '2024-10-10', 'lacinia erat vestibulum sed magna at nunc commodo placerat praesent', 23);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (92, 'Toughjoyfax', 'tortor eu pede', '2023-08-20', '2024-06-22', 'vulputate justo in blandit ultrices enim lorem ipsum dolor sit', 75);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (93, 'Zaam-Dox', 'at turpis a', '2023-08-09', '2024-02-18', null, 55);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (94, 'Overhold', 'in eleifend quam', '2023-09-08', '2024-01-29', 'at nibh in hac habitasse platea dictumst aliquam augue quam', 78);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (95, 'Quo Lux', 'proin interdum mauris', '2022-12-13', '2024-07-17', 'auctor sed tristique in tempus sit amet sem fusce consequat', 71);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (96, 'Transcof', 'convallis tortor risus', '2023-06-05', '2024-02-28', 'massa volutpat convallis morbi odio odio elementum eu interdum eu', 57);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (97, 'Ventosanzap', 'id justo sit', '2023-07-19', '2023-11-22', 'curae nulla dapibus dolor vel est donec odio justo sollicitudin', 84);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (98, 'Voltsillam', 'ipsum primis in', '2023-10-24', '2024-03-04', 'eu magna vulputate luctus cum sociis natoque penatibus et magnis', 68);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (99, 'Veribet', 'convallis duis consequat', '2023-05-05', '2024-07-10', 'in consequat ut nulla sed accumsan felis ut at dolor', 11);
insert into Proyecto (id, nombre, objetivo, fecha_inicio, fecha_fin, descripcion, responsable) values (100, 'Matsoft', 'vestibulum rutrum rutrum', '2023-08-24', '2024-08-23', 'quam suspendisse potenti nullam porttitor lacus at turpis donec posuere', 56);

insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (1, 'Accounting', '2023-04-18', '2024-08-14', 'Pendiente', 'Urgente', 'amet lobortis sapien sapien non mi integer ac neque duis', 14);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (2, 'Services', '2023-03-17', '2024-03-29', 'En Proceso', 'Urgente', 'in felis eu sapien cursus vestibulum proin eu mi nulla', 23);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (3, 'Services', '2023-08-12', '2024-08-09', 'En Proceso', 'Normal', 'non velit donec diam neque vestibulum eget vulputate ut ultrices', 29);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (4, 'Training', '2023-06-09', '2023-12-17', 'En Proceso', 'Baja', 'amet diam in magna bibendum imperdiet nullam orci pede venenatis', 45);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (5, 'Accounting', '2023-10-16', '2024-04-12', 'Pendiente', 'Alta', 'quis turpis sed ante vivamus tortor duis mattis egestas metus', 83);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (6, 'Marketing', '2023-03-28', '2024-01-30', 'Cancelada', 'Urgente', 'nulla quisque arcu libero rutrum ac lobortis vel dapibus at', 66);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (7, 'Support', '2023-04-20', '2023-11-20', 'Pendiente', 'Baja', 'ultrices vel augue vestibulum ante ipsum primis in faucibus orci', 69);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (8, 'Engineering', '2022-11-26', '2024-07-27', 'En Proceso', 'Normal', 'erat id mauris vulputate elementum nullam varius nulla facilisi cras', 13);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (9, 'Research and Development', '2023-08-13', '2024-10-08', 'Pendiente', 'Normal', 'at nibh in hac habitasse platea dictumst aliquam augue quam', 27);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (10, 'Sales', '2022-11-15', '2024-08-22', 'En Proceso', 'Urgente', 'etiam pretium iaculis justo in hac habitasse platea dictumst etiam', 90);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (11, 'Legal', '2023-03-12', '2024-05-21', 'Pendiente', 'Urgente', 'ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent', 57);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (12, 'Engineering', '2022-12-12', '2024-05-06', 'Cancelada', 'Alta', 'in faucibus orci luctus et ultrices posuere cubilia curae nulla', 8);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (13, 'Accounting', '2023-05-01', '2024-05-06', 'Cancelada', 'Alta', 'ut erat id mauris vulputate elementum nullam varius nulla facilisi', 4);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (14, 'Marketing', '2023-05-17', '2024-05-13', 'Cancelada', 'Urgente', 'feugiat et eros vestibulum ac est lacinia nisi venenatis tristique', 63);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (15, 'Business Development', '2023-07-18', '2024-01-27', 'Pendiente', 'Alta', 'erat curabitur gravida nisi at nibh in hac habitasse platea', 91);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (16, 'Business Development', '2023-01-18', '2023-12-19', 'Pendiente', 'Alta', 'quis augue luctus tincidunt nulla mollis molestie lorem quisque ut', 56);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (17, 'Engineering', '2023-03-19', '2024-07-18', 'Pendiente', 'Urgente', 'mauris non ligula pellentesque ultrices phasellus id sapien in sapien', 60);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (18, 'Engineering', '2023-09-01', '2024-05-25', 'Terminada', 'Baja', 'viverra dapibus nulla suscipit ligula in lacus curabitur at ipsum', 87);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (19, 'Sales', '2022-11-16', '2024-04-01', 'Cancelada', 'Alta', 'natoque penatibus et magnis dis parturient montes nascetur ridiculus mus', 63);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (20, 'Services', '2022-12-03', '2024-04-17', 'En Proceso', 'Urgente', 'morbi ut odio cras mi pede malesuada in imperdiet et', 29);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (21, 'Accounting', '2023-05-20', '2024-09-08', 'En Proceso', 'Alta', 'cum sociis natoque penatibus et magnis dis parturient montes nascetur', 23);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (22, 'Marketing', '2023-09-21', '2023-11-22', 'Pendiente', 'Baja', 'facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt', 79);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (23, 'Engineering', '2023-10-10', '2024-06-06', 'En Proceso', 'Normal', 'aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien', 75);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (24, 'Support', '2022-11-27', '2024-11-12', 'Terminada', 'Baja', 'primis in faucibus orci luctus et ultrices posuere cubilia curae', 37);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (25, 'Training', '2023-06-05', '2024-06-29', 'Pendiente', 'Urgente', 'erat fermentum justo nec condimentum neque sapien placerat ante nulla', 82);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (26, 'Legal', '2023-05-22', '2024-01-19', 'En Proceso', 'Normal', 'vestibulum proin eu mi nulla ac enim in tempor turpis', 18);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (27, 'Legal', '2023-04-24', '2024-01-31', 'En Proceso', 'Urgente', 'purus sit amet nulla quisque arcu libero rutrum ac lobortis', 78);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (28, 'Accounting', '2023-06-19', '2024-01-17', 'Terminada', 'Baja', 'pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis', 34);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (29, 'Legal', '2023-10-29', '2024-09-10', 'Pendiente', 'Normal', 'platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum', 30);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (30, 'Services', '2023-07-10', '2023-11-18', 'Terminada', 'Urgente', 'lobortis ligula sit amet eleifend pede libero quis orci nullam', 70);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (31, 'Product Management', '2023-04-16', '2024-02-11', 'Pendiente', 'Baja', 'vel pede morbi porttitor lorem id ligula suspendisse ornare consequat', 41);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (32, 'Product Management', '2023-07-28', '2024-06-20', 'Pendiente', 'Normal', 'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum', 49);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (33, 'Training', '2023-08-30', '2023-11-22', 'Pendiente', 'Urgente', 'hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis', 80);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (34, 'Training', '2022-11-20', '2024-03-15', 'Cancelada', 'Alta', 'consequat ut nulla sed accumsan felis ut at dolor quis', 82);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (35, 'Legal', '2022-12-25', '2024-07-22', 'En Proceso', 'Normal', 'elit ac nulla sed vel enim sit amet nunc viverra', 95);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (36, 'Product Management', '2023-11-05', '2024-07-03', 'En Proceso', 'Urgente', 'ac consequat metus sapien ut nunc vestibulum ante ipsum primis', 55);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (37, 'Support', '2023-04-30', '2024-10-19', 'Pendiente', 'Alta', 'vestibulum ante ipsum primis in faucibus orci luctus et ultrices', 93);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (38, 'Services', '2023-05-10', '2024-07-27', 'Pendiente', 'Urgente', 'nisl venenatis lacinia aenean sit amet justo morbi ut odio', 91);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (39, 'Business Development', '2023-08-29', '2024-03-26', 'En Proceso', 'Urgente', 'pede ac diam cras pellentesque volutpat dui maecenas tristique est', 9);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (40, 'Research and Development', '2023-02-20', '2024-11-11', 'Terminada', 'Urgente', 'nulla tellus in sagittis dui vel nisl duis ac nibh', 53);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (41, 'Sales', '2022-11-21', '2024-05-27', 'Pendiente', 'Alta', 'at feugiat non pretium quis lectus suspendisse potenti in eleifend', 10);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (42, 'Training', '2023-04-02', '2024-03-19', 'En Proceso', 'Baja', 'molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget', 48);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (43, 'Human Resources', '2023-10-18', '2024-07-03', 'Pendiente', 'Normal', 'elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis', 25);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (44, 'Marketing', '2023-03-20', '2024-01-16', 'Pendiente', 'Urgente', 'justo aliquam quis turpis eget elit sodales scelerisque mauris sit', 60);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (45, 'Human Resources', '2023-06-03', '2024-07-06', 'Cancelada', 'Urgente', 'tellus nisi eu orci mauris lacinia sapien quis libero nullam', 40);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (46, 'Training', '2023-03-10', '2024-04-29', 'Terminada', 'Normal', 'in libero ut massa volutpat convallis morbi odio odio elementum', 38);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (47, 'Accounting', '2023-08-16', '2024-10-13', 'En Proceso', 'Urgente', 'fermentum justo nec condimentum neque sapien placerat ante nulla justo', 72);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (48, 'Legal', '2023-11-10', '2024-10-27', 'Cancelada', 'Normal', 'volutpat quam pede lobortis ligula sit amet eleifend pede libero', 95);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (49, 'Engineering', '2022-12-07', '2024-04-05', 'Terminada', 'Alta', 'integer non velit donec diam neque vestibulum eget vulputate ut', 43);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (50, 'Support', '2023-10-08', '2024-06-26', 'Pendiente', 'Baja', 'vel nulla eget eros elementum pellentesque quisque porta volutpat erat', 55);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (51, 'Services', '2023-10-01', '2023-12-02', 'Pendiente', 'Alta', 'vulputate luctus cum sociis natoque penatibus et magnis dis parturient', 23);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (52, 'Accounting', '2023-11-12', '2023-12-14', 'En Proceso', 'Normal', 'curae nulla dapibus dolor vel est donec odio justo sollicitudin', 91);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (53, 'Human Resources', '2023-08-12', '2024-04-03', 'En Proceso', 'Normal', 'mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et', 54);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (54, 'Marketing', '2023-03-02', '2023-11-14', 'Cancelada', 'Baja', 'et eros vestibulum ac est lacinia nisi venenatis tristique fusce', 96);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (55, 'Legal', '2023-06-01', '2024-05-21', 'Cancelada', 'Normal', 'tempor convallis nulla neque libero convallis eget eleifend luctus ultricies', 91);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (56, 'Human Resources', '2023-04-22', '2024-09-10', 'Cancelada', 'Urgente', 'aliquam convallis nunc proin at turpis a pede posuere nonummy', 63);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (57, 'Research and Development', '2023-01-20', '2024-01-29', 'Cancelada', 'Urgente', 'penatibus et magnis dis parturient montes nascetur ridiculus mus etiam', 48);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (58, 'Marketing', '2023-04-01', '2024-09-19', 'Cancelada', 'Alta', 'interdum in ante vestibulum ante ipsum primis in faucibus orci', 19);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (59, 'Business Development', '2023-08-19', '2024-02-25', 'En Proceso', 'Urgente', 'duis aliquam convallis nunc proin at turpis a pede posuere', 65);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (60, 'Accounting', '2023-03-19', '2023-11-15', 'Terminada', 'Normal', 'nam nulla integer pede justo lacinia eget tincidunt eget tempus', 99);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (61, 'Marketing', '2022-11-16', '2024-06-16', 'En Proceso', 'Baja', 'quis justo maecenas rhoncus aliquam lacus morbi quis tortor id', 98);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (62, 'Engineering', '2023-03-27', '2024-09-02', 'Terminada', 'Normal', 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper', 11);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (63, 'Training', '2023-03-14', '2024-09-25', 'Pendiente', 'Urgente', 'ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean', 64);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (64, 'Human Resources', '2023-07-10', '2024-08-01', 'Terminada', 'Alta', 'diam erat fermentum justo nec condimentum neque sapien placerat ante', 90);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (65, 'Business Development', '2023-03-09', '2024-07-20', 'Terminada', 'Urgente', 'gravida nisi at nibh in hac habitasse platea dictumst aliquam', 74);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (66, 'Accounting', '2023-06-26', '2024-03-09', 'Terminada', 'Baja', 'semper est quam pharetra magna ac consequat metus sapien ut', 44);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (67, 'Training', '2023-07-16', '2024-08-10', 'Pendiente', 'Urgente', 'in libero ut massa volutpat convallis morbi odio odio elementum', 30);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (68, 'Human Resources', '2022-12-12', '2024-05-11', 'Pendiente', 'Normal', 'mauris vulputate elementum nullam varius nulla facilisi cras non velit', 10);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (69, 'Services', '2023-01-28', '2023-12-23', 'Terminada', 'Baja', 'eleifend luctus ultricies eu nibh quisque id justo sit amet', 96);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (70, 'Business Development', '2023-06-26', '2023-12-23', 'Cancelada', 'Alta', 'lorem quisque ut erat curabitur gravida nisi at nibh in', 13);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (71, 'Services', '2023-04-10', '2024-03-18', 'Cancelada', 'Baja', 'amet diam in magna bibendum imperdiet nullam orci pede venenatis', 89);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (72, 'Marketing', '2023-10-08', '2024-09-17', 'En Proceso', 'Alta', 'non mi integer ac neque duis bibendum morbi non quam', 98);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (73, 'Research and Development', '2023-03-12', '2024-03-09', 'En Proceso', 'Alta', 'diam erat fermentum justo nec condimentum neque sapien placerat ante', 44);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (74, 'Support', '2023-09-07', '2024-02-03', 'Pendiente', 'Urgente', 'dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis', 26);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (75, 'Business Development', '2023-10-16', '2024-01-22', 'Terminada', 'Baja', 'erat quisque erat eros viverra eget congue eget semper rutrum', 54);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (76, 'Services', '2023-09-09', '2024-03-07', 'Cancelada', 'Alta', 'metus sapien ut nunc vestibulum ante ipsum primis in faucibus', 100);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (77, 'Support', '2023-02-06', '2024-10-11', 'Terminada', 'Urgente', 'amet sem fusce consequat nulla nisl nunc nisl duis bibendum', 45);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (78, 'Human Resources', '2023-03-11', '2024-08-16', 'Terminada', 'Baja', 'massa id nisl venenatis lacinia aenean sit amet justo morbi', 8);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (79, 'Services', '2023-04-27', '2024-09-05', 'En Proceso', 'Normal', 'massa donec dapibus duis at velit eu est congue elementum', 19);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (80, 'Sales', '2023-01-18', '2024-05-03', 'En Proceso', 'Normal', 'velit vivamus vel nulla eget eros elementum pellentesque quisque porta', 12);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (81, 'Sales', '2023-07-24', '2023-12-01', 'Cancelada', 'Alta', 'placerat ante nulla justo aliquam quis turpis eget elit sodales', 8);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (82, 'Business Development', '2022-11-27', '2024-01-14', 'Cancelada', 'Baja', 'pretium quis lectus suspendisse potenti in eleifend quam a odio', 80);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (83, 'Business Development', '2023-07-20', '2024-05-19', 'En Proceso', 'Baja', 'malesuada in imperdiet et commodo vulputate justo in blandit ultrices', 90);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (84, 'Engineering', '2023-01-17', '2024-07-03', 'Pendiente', 'Baja', 'enim sit amet nunc viverra dapibus nulla suscipit ligula in', 89);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (85, 'Training', '2023-06-17', '2024-05-12', 'Pendiente', 'Urgente', 'sed ante vivamus tortor duis mattis egestas metus aenean fermentum', 2);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (86, 'Business Development', '2023-08-29', '2024-07-30', 'Terminada', 'Alta', 'dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum', 47);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (87, 'Product Management', '2023-02-02', '2024-03-23', 'Cancelada', 'Alta', 'eget tempus vel pede morbi porttitor lorem id ligula suspendisse', 70);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (88, 'Business Development', '2022-12-30', '2024-09-29', 'Pendiente', 'Urgente', 'a odio in hac habitasse platea dictumst maecenas ut massa', 33);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (89, 'Services', '2023-03-21', '2024-03-06', 'Pendiente', 'Normal', 'a ipsum integer a nibh in quis justo maecenas rhoncus', 70);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (90, 'Research and Development', '2023-08-06', '2024-05-27', 'Pendiente', 'Urgente', 'ullamcorper augue a suscipit nulla elit ac nulla sed vel', 19);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (91, 'Human Resources', '2023-02-15', '2024-10-17', 'En Proceso', 'Baja', 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus', 32);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (92, 'Product Management', '2022-12-11', '2024-07-23', 'En Proceso', 'Baja', 'felis sed interdum venenatis turpis enim blandit mi in porttitor', 60);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (93, 'Product Management', '2023-04-04', '2024-07-01', 'Pendiente', 'Normal', 'curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus', 75);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (94, 'Support', '2022-11-15', '2024-09-11', 'Pendiente', 'Urgente', 'mauris enim leo rhoncus sed vestibulum sit amet cursus id', 90);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (95, 'Training', '2023-08-21', '2024-08-22', 'Terminada', 'Urgente', 'ipsum integer a nibh in quis justo maecenas rhoncus aliquam', 60);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (96, 'Services', '2023-10-28', '2024-02-01', 'Pendiente', 'Alta', 'consequat lectus in est risus auctor sed tristique in tempus', 26);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (97, 'Support', '2023-09-26', '2024-09-13', 'Terminada', 'Baja', 'pretium iaculis diam erat fermentum justo nec condimentum neque sapien', 48);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (98, 'Support', '2023-10-03', '2024-11-08', 'Cancelada', 'Urgente', 'maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus', 21);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (99, 'Engineering', '2023-04-22', '2024-04-26', 'Terminada', 'Normal', 'integer a nibh in quis justo maecenas rhoncus aliquam lacus', 2);
insert into Tarea (id, nombre, fecha_inicio, fecha_fin, estado, prioridad, descripcion, id_proyecto) values (100, 'Human Resources', '2023-03-23', '2024-07-20', 'En Proceso', 'Alta', 'integer aliquet massa id lobortis convallis tortor risus dapibus augue', 12);

insert into Tarea_Participante (id_tarea, id_participante) values (93, 63);
insert into Tarea_Participante (id_tarea, id_participante) values (81, 8);
insert into Tarea_Participante (id_tarea, id_participante) values (76, 77);
insert into Tarea_Participante (id_tarea, id_participante) values (36, 17);
insert into Tarea_Participante (id_tarea, id_participante) values (74, 88);
insert into Tarea_Participante (id_tarea, id_participante) values (17, 38);
insert into Tarea_Participante (id_tarea, id_participante) values (52, 94);
insert into Tarea_Participante (id_tarea, id_participante) values (14, 68);
insert into Tarea_Participante (id_tarea, id_participante) values (33, 16);
insert into Tarea_Participante (id_tarea, id_participante) values (4, 92);
insert into Tarea_Participante (id_tarea, id_participante) values (66, 42);
insert into Tarea_Participante (id_tarea, id_participante) values (88, 98);
insert into Tarea_Participante (id_tarea, id_participante) values (90, 95);
insert into Tarea_Participante (id_tarea, id_participante) values (34, 42);
insert into Tarea_Participante (id_tarea, id_participante) values (4, 3);
insert into Tarea_Participante (id_tarea, id_participante) values (62, 17);
insert into Tarea_Participante (id_tarea, id_participante) values (92, 59);
insert into Tarea_Participante (id_tarea, id_participante) values (26, 40);
insert into Tarea_Participante (id_tarea, id_participante) values (55, 91);
insert into Tarea_Participante (id_tarea, id_participante) values (23, 89);
insert into Tarea_Participante (id_tarea, id_participante) values (79, 46);
insert into Tarea_Participante (id_tarea, id_participante) values (67, 54);
insert into Tarea_Participante (id_tarea, id_participante) values (74, 26);
insert into Tarea_Participante (id_tarea, id_participante) values (48, 96);
insert into Tarea_Participante (id_tarea, id_participante) values (59, 88);
insert into Tarea_Participante (id_tarea, id_participante) values (25, 64);
insert into Tarea_Participante (id_tarea, id_participante) values (14, 69);
insert into Tarea_Participante (id_tarea, id_participante) values (11, 29);
insert into Tarea_Participante (id_tarea, id_participante) values (7, 8);
insert into Tarea_Participante (id_tarea, id_participante) values (55, 23);
insert into Tarea_Participante (id_tarea, id_participante) values (60, 91);
insert into Tarea_Participante (id_tarea, id_participante) values (89, 95);
insert into Tarea_Participante (id_tarea, id_participante) values (1, 54);
insert into Tarea_Participante (id_tarea, id_participante) values (66, 75);
insert into Tarea_Participante (id_tarea, id_participante) values (44, 65);
insert into Tarea_Participante (id_tarea, id_participante) values (29, 16);
insert into Tarea_Participante (id_tarea, id_participante) values (31, 23);
insert into Tarea_Participante (id_tarea, id_participante) values (23, 88);
insert into Tarea_Participante (id_tarea, id_participante) values (36, 64);
insert into Tarea_Participante (id_tarea, id_participante) values (80, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (96, 69);
insert into Tarea_Participante (id_tarea, id_participante) values (30, 58);
insert into Tarea_Participante (id_tarea, id_participante) values (76, 49);
insert into Tarea_Participante (id_tarea, id_participante) values (19, 61);
insert into Tarea_Participante (id_tarea, id_participante) values (79, 84);
insert into Tarea_Participante (id_tarea, id_participante) values (73, 75);
insert into Tarea_Participante (id_tarea, id_participante) values (99, 9);
insert into Tarea_Participante (id_tarea, id_participante) values (27, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (1, 73);
insert into Tarea_Participante (id_tarea, id_participante) values (15, 41);
insert into Tarea_Participante (id_tarea, id_participante) values (41, 62);
insert into Tarea_Participante (id_tarea, id_participante) values (66, 79);
insert into Tarea_Participante (id_tarea, id_participante) values (65, 45);
insert into Tarea_Participante (id_tarea, id_participante) values (10, 20);
insert into Tarea_Participante (id_tarea, id_participante) values (20, 52);
insert into Tarea_Participante (id_tarea, id_participante) values (12, 30);
insert into Tarea_Participante (id_tarea, id_participante) values (36, 87);
insert into Tarea_Participante (id_tarea, id_participante) values (90, 65);
insert into Tarea_Participante (id_tarea, id_participante) values (29, 89);
insert into Tarea_Participante (id_tarea, id_participante) values (16, 9);
insert into Tarea_Participante (id_tarea, id_participante) values (17, 89);
insert into Tarea_Participante (id_tarea, id_participante) values (40, 38);
insert into Tarea_Participante (id_tarea, id_participante) values (38, 27);
insert into Tarea_Participante (id_tarea, id_participante) values (95, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (4, 94);
insert into Tarea_Participante (id_tarea, id_participante) values (8, 80);
insert into Tarea_Participante (id_tarea, id_participante) values (73, 89);
insert into Tarea_Participante (id_tarea, id_participante) values (9, 69);
insert into Tarea_Participante (id_tarea, id_participante) values (10, 32);
insert into Tarea_Participante (id_tarea, id_participante) values (92, 96);
insert into Tarea_Participante (id_tarea, id_participante) values (37, 53);
insert into Tarea_Participante (id_tarea, id_participante) values (2, 84);
insert into Tarea_Participante (id_tarea, id_participante) values (71, 20);
insert into Tarea_Participante (id_tarea, id_participante) values (85, 47);
insert into Tarea_Participante (id_tarea, id_participante) values (92, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (5, 41);
insert into Tarea_Participante (id_tarea, id_participante) values (90, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (75, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (88, 7);
insert into Tarea_Participante (id_tarea, id_participante) values (61, 45);
insert into Tarea_Participante (id_tarea, id_participante) values (3, 75);
insert into Tarea_Participante (id_tarea, id_participante) values (36, 3);
insert into Tarea_Participante (id_tarea, id_participante) values (57, 14);
insert into Tarea_Participante (id_tarea, id_participante) values (97, 23);
insert into Tarea_Participante (id_tarea, id_participante) values (75, 56);
insert into Tarea_Participante (id_tarea, id_participante) values (5, 44);
insert into Tarea_Participante (id_tarea, id_participante) values (83, 9);
insert into Tarea_Participante (id_tarea, id_participante) values (42, 2);
insert into Tarea_Participante (id_tarea, id_participante) values (60, 64);
insert into Tarea_Participante (id_tarea, id_participante) values (82, 74);
insert into Tarea_Participante (id_tarea, id_participante) values (54, 27);
insert into Tarea_Participante (id_tarea, id_participante) values (42, 73);
insert into Tarea_Participante (id_tarea, id_participante) values (35, 55);
insert into Tarea_Participante (id_tarea, id_participante) values (69, 36);
insert into Tarea_Participante (id_tarea, id_participante) values (100, 36);
insert into Tarea_Participante (id_tarea, id_participante) values (98, 15);
insert into Tarea_Participante (id_tarea, id_participante) values (83, 36);
insert into Tarea_Participante (id_tarea, id_participante) values (67, 3);
insert into Tarea_Participante (id_tarea, id_participante) values (69, 48);
insert into Tarea_Participante (id_tarea, id_participante) values (54, 84);

insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 68);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 81);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (3, 64);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 49);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (2, 50);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (5, 55);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 57);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 30);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 58);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (1, 22);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (7, 77);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (6, 15);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (5, 45);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (12, 77);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (12, 21);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (15, 63);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (11, 79);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (10, 41);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (10, 47);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (17, 35);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (17, 83);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (20, 71);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (18, 86);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (24, 49);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (21, 50);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (23, 35);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (26, 75);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (24, 55);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (26, 59);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (25, 93);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (24, 47);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (23, 76);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (24, 97);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (32, 52);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (33, 90);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (28, 42);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (29, 78);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (28, 85);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (32, 96);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (36, 97);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (31, 59);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (39, 91);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (37, 65);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (39, 66);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (38, 49);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (46, 91);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (47, 76);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (41, 66);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (47, 60);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (45, 95);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (43, 63);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (42, 62);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (48, 64);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (52, 60);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (48, 76);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (56, 100);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (56, 64);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (48, 71);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (58, 66);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (56, 66);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (60, 75);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (59, 77);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (63, 77);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (61, 83);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (59, 80);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (64, 87);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (62, 97);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (67, 81);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (68, 89);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (62, 95);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (69, 79);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (70, 79);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (73, 96);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (66, 75);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (75, 92);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (69, 97);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (76, 98);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (74, 94);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (70, 84);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (71, 93);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (77, 99);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (75, 95);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (81, 93);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (79, 86);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (82, 93);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (79, 94);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (79, 99);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (88, 94);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (84, 97);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (84, 99);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (90, 92);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (89, 99);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (86, 97);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (94, 96);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (95, 96);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (87, 99);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (92, 100);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (94, 100);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (99, 100);
insert into Tarea_Tarea (id_tarea1, id_tarea2) values (93, 100);

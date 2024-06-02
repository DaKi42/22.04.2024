use [master];
go

if db_id('Academy') is not null
begin
  drop database [Academy];
end
go

create database [Academy];
go

use [Academy];
go

create table [Departments]
(
  [Id] int not null identity(1, 1) primary key,
  [Financing] money not null check ([Financing] >= 0.0) default 0.0,
  [Name] nvarchar(MAX) not null unique check ([Name] <> N''),
  [FacultyId] int not null
)
go

create table [Faculties]
(
  [Id] int not null identity(1, 1) primary key,
  [Name] nvarchar(MAX) not null unique check ([Name] <> N'')
)
go

create table [Groups]
(
  [Id] int not null identity(1, 1) primary key,
  [Name] nvarchar(MAX) not null unique check ([Name] <> N''),
  [Year] int not null check ([Year] between 1 and 5),
  [DepartmentId] int not null
)
go

create table [GroupsLectures]
(
  [Id] int not null identity(1, 1) primary key,
  [DayOfWeek] int not null check ([DayOfWeek] between 1 and 7),
  [GroupId] int not null,
  [LectureId] int not null
)
go

create table [Lectures]
(
  [Id] int not null identity(1, 1) primary key,
  [LectureRoom] nvarchar(MAX) not null check ([LectureRoom] <> N''),
  [SubjectId] int not null,
  [TeacherId] int not null
)
go

create table [Subjects]
(
  [Id] int not null identity(1, 1) primary key,
  [Name] nvarchar(100) not null unique check ([Name] <> N'')
)
go

create table [Teachers]
(
  [Id] int not null identity(1, 1) primary key,
  [Name] nvarchar(MAX) not null check ([Name] <> N''),
  [Salary] money not null check ([Salary] > 0.0),
  [Surname] nvarchar(MAX) not null check ([Surname] <> N'')
)
go

alter table [Departments]
add foreign key ([FacultyId]) references [Faculties]([Id]);
go

alter table [Groups]
add foreign key ([DepartmentId]) references [Departments]([Id])
go

alter table [GroupsLectures]
add foreign key ([GroupId]) references [Groups]([Id])
go

alter table [GroupsLectures]
add foreign key ([LectureId]) references [Lectures]([Id])
go

alter table [Lectures]
add foreign key ([SubjectId]) references [Subjects]([Id])
go

alter table [Lectures]
add foreign key ([TeacherId]) references [Teachers]([Id])
go

insert into [Faculties] ([Name])
values (N'Computer Science')

insert into [Departments] ([Financing], [Name], [FacultyId])
values (300000, N'Software Development', 1),
       (200000, N'Information Systems', 1)

insert into [Teachers] ([Name], [Salary], [Surname])
values (N'Illia', 60000, N'Bondar'), 
       (N'Alisa', 65000, N'Ivanova'),
       (N'Jack', 58000, N'Underhill'), 
       (N'Michael', 63000, N'Jackson'),
       (N'Emily', 62000, N'Clark'), 
       (N'Chris', 64000, N'Madson')


insert into [Subjects] ([Name])
values (N'Algorithms'), (N'Computer Networks'),
       (N'Software Engineering'), (N'Web Development'),
       (N'Operating Systems'), (N'Data Structures')


insert into [Lectures] ([LectureRoom], [SubjectId], [TeacherId])
values (N'D201', 1, 1),
       (N'D202', 2, 2),
       (N'D203', 3, 3),
       (N'D204', 4, 4),
       (N'D205', 5, 5),
       (N'D206', 6, 6)


insert into [Groups] ([Name], [Year], [DepartmentId])
values (N'CS 101', 1, 1), (N'IS 201', 1, 2)


insert into [GroupsLectures] ([DayOfWeek], [GroupId], [LectureId])
values (1, 1, 1), (2, 1, 2), (3, 1, 3),
       (1, 2, 1), (2, 2, 2), (3, 2, 3);

SELECT * FROM Faculties

SELECT * FROM Departments

SELECT * FROM Teachers

SELECT * FROM Subjects

SELECT * FROM Lectures

SELECT * FROM Groups

SELECT * FROM GroupsLectures

-- Вывести количество преподавателей кафедры “Software Development”.
SELECT COUNT(DISTINCT T.Id) AS [TeachersCount]
FROM Teachers AS T INNER JOIN Lectures AS L ON T.Id = L.TeacherId
INNER JOIN Subjects AS S ON L.SubjectId = S.Id
INNER JOIN Departments AS D ON S.Id = D.Id
WHERE D.Name = N'Software Development'

-- Вывести количество лекций, которые читает преподаватель “Dave McQueen”.
SELECT COUNT(*) AS [LectureCount]
FROM Lectures AS L INNER JOIN Teachers AS T ON L.TeacherId = T.Id
WHERE T.[Name] = N'Dave' AND T.Surname = N'McQueen'

-- Вывести количество занятий, проводимых в аудитории “D201”.
SELECT COUNT(*) AS [LectureCount]
FROM GroupsLectures AS GL
INNER JOIN Lectures AS L ON GL.LectureId = L.Id
WHERE L.LectureRoom = N'D201'

-- Вывести названия аудиторий и количество лекций, проводимых в них.
SELECT L.LectureRoom, COUNT(GL.LectureId) AS [LectureCount]
FROM Lectures AS L INNER JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
GROUP BY L.LectureRoom

-- Вывести количество студентов, посещающих лекции преподавателя “Jack Underhill”.
SELECT COUNT(*) AS [StudentCount]
FROM GroupsLectures AS GL
INNER JOIN Lectures AS L ON GL.LectureId = L.Id
INNER JOIN Teachers AS T ON L.TeacherId = T.Id
WHERE T.[Name] = N'Jack' AND T.Surname = N'Underhill'

-- Вывести среднюю ставку преподавателей факультета “Computer Science”.
SELECT AVG(T.Salary) AS [AverageSalary]
FROM Teachers AS T
INNER JOIN Lectures AS L ON T.Id = L.TeacherId
INNER JOIN Subjects AS S ON L.SubjectId = S.Id
INNER JOIN Departments AS D ON S.Id = D.Id
INNER JOIN Faculties AS F ON D.FacultyId = F.Id
WHERE F.[Name] = N'Computer Science'

-- Вывести минимальное и максимальное количество студентов среди всех групп.
SELECT MIN(StudentsCount) AS [MinStudentsCount], MAX(StudentsCount) AS [MaxStudentsCount]
FROM (SELECT DepartmentId, COUNT(*) AS StudentsCount FROM Groups GROUP BY DepartmentId) AS GroupStudents

-- Вывести средний фонд финансирования кафедр.
SELECT AVG(Financing) AS [AverageFinancing] FROM Departments

-- Вывести полные имена преподавателей и количество читаемых ими дисциплин.
SELECT T.[Name] + ' ' + T.Surname AS [FullName], COUNT(*) AS [SubjectsCount]
FROM Teachers AS T INNER JOIN Lectures AS L ON T.Id = L.TeacherId
GROUP BY T.[Name], T.Surname

-- Вывести количество лекций в каждый день недели.
SELECT DayOfWeek, COUNT(*) AS [LectureCount] FROM GroupsLectures GROUP BY DayOfWeek

-- Вывести номера аудиторий и количество кафедр, чьи лекции в них читаются.
SELECT L.LectureRoom, COUNT(DISTINCT D.Id) AS [DepartmentsCount]
FROM Lectures AS L
INNER JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
INNER JOIN Groups AS G ON GL.GroupId = G.Id
INNER JOIN Departments AS D ON G.DepartmentId = D.Id
GROUP BY L.LectureRoom

-- Вывести названия факультетов и количество дисциплин, которые на них читаются.
SELECT F.[Name] AS [FacultyName], COUNT(DISTINCT S.Id) AS [SubjectsCount]
FROM Faculties AS F
INNER JOIN Departments AS D ON F.Id = D.FacultyId
INNER JOIN Groups AS G ON D.Id = G.DepartmentId
INNER JOIN GroupsLectures AS GL ON G.Id = GL.GroupId
INNER JOIN Lectures AS L ON GL.LectureId = L.Id
INNER JOIN Subjects AS S ON L.SubjectId = S.Id
GROUP BY F.[Name]

-- Вывести количество лекций для каждой пары преподаватель-аудитория.
SELECT T.[Name] + ' ' + T.Surname AS [TeacherFullName], L.LectureRoom, COUNT(*) AS [LectureCount]
FROM Lectures AS L INNER JOIN Teachers AS T ON L.TeacherId = T.Id
GROUP BY T.[Name], T.Surname, L.LectureRoom
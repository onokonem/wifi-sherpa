DROP TABLE IF EXISTS users;

create table users(userid integer primary key autoincrement, username cahr(16) not null unique);
	insert into users(username) values ("hryamzik");
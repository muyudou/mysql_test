#查看表的列数
select count(*) from information_schema.columns where table_schema='featuredb' and table_name = 'virus_head';

#从文件载入数据
LOAD DATA LOCAL INFILE '/home/xlf/pe_feature/feature/mysql/normal/id_normal_file1' INTO TABLE normals FIELDS TERMINATED BY '~';

#按照某一个字段分组，并且获得每个字段的个数
select image_base, count(*) from virus_head group by image_base;

#更新某一列
update table virus set file_id = 945 where file_id=0

#增加外键
alter table virus add constraint FK_ID_headv foreign key(file_id) references virus_head(file_id) on delete cascade on update cascade;

#查看外键
select * from information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_NAME='normal_head';
#删除外键
alter table virus_sec drop foreign key FK_ID_sec;

#查询重复行
select * from virus where file_name in (select file_name from virus group by file_name having count(file_name) > 1);
#也可以使用自链接查询name相同，但id不同的行，
select v1.file_name, v2.file_name from virus as v1, virus as v2 where v1.file_id != v2.file_id and v1.file_name = v2.file_name
v1,v2是相同的表，但是使用别名当成不同的表，则可以查询，如果不使用查询则会出现歧义


删除重复的列
delete from select_id where id in (select id from select_id group by file_id having count(file_id) > 1);
报错，原因是不能在选择表的时候更新表
替代方案：创建临时表
create table tmp as select min(id) as col1 from select_id group by file_id;
delete from select_id where id not in (select col1 from tmp);
drop table tmp;

然后插入表中
insert into union_normal select * from union_all_normal where file_id in (select file_id from select_id);

#查询表之间的id与name是否匹配
select virus.file_id, virus.file_name, virus_sec.file_id, virus_sec.file_name from virus, virus_sec where virus.file_id = virus_sec.file_id;


#增加主键
alter table virus add primary key(file_id)
#修改某列为自动增量
alter table virus change id id integer not null auto_increment=1;


#创建视图
CREATE VIEW sec_num_infov AS select file_id, file_name, section_num, Sec_Num from virus_head natural join virus_sec;
#查看视图创建语句
SHOW CREATE VIEW sec_num_info;
SELECT * FROM information_schema.views;
#删除试图
DROP VIEW sec_num_info;

#内部链接
select virus.file_name, virus_head.file_name from virus INNER JOIN virus_head on virus.file_id = virus_head.file_id;
#内部连接其实就是等值链接，即上面内容等同于下面
select virus.file_name, virus_head.file_name from virus, virus_head where virus.file_id = virus_head.file_id;

#自然链接去除重复的列
select * from virus natural join virus_head;
这句等价于 select * from virus, virus_head where virus.file_id = virus_head.file_id
#如果去掉natural join则不会去除重复列，
#等值连接会包括重复的行，如果要去除重复的行，则只能一个表使用c.*，另外的表指名选定的列，只能自己自动去除相同的列


以下连接包含两个表的所有列，相同的列会重复出现：
select * from virus, virus_head limit 1;
select * from virus inner join virus_head on virus.file_id = virus_head.file_id limit 1;
select * from virus left join virus_head on virus.file_id = virus_head.file_id limit 1;

使用using子句取代on子句会消去重复的列
 select * from virus inner/left join virus_head using(file_id) limit 1; 
file_id只出现一次，但file_name还是两次
 select * from virus inner/left join virus_head using(file_id, file_name) limit 1; 
file_id,file_name都出现一次

以下还是出现重复了
select * from virus left join virus_head on virus.file_id=virus_head.file_id left join virus_sec on virus_head.file_id = virus_sec.file_id limit 1;
以下消除,两句等价，所以还是natural方便呀，natural相等于inner/left join加上using 子句，且using列表中是所有相同的列，即所有相同的列只出现一次
select * from virus inner/left join virus_head using(file_id, file_name) inner/left join virus_sec using(file_id, file_name) limit 1;
select * from virus natural join virus_head natural join virus_sec limit 1;

natural join = inner join..using(common_list)
natural left/right join = left/right join using(common_list)

对于四个表的合并，以下两句等价，而且可以去重
natural:select * from virus natural join virus_head natural join virus_sec natural join virus_dll;
inner join using:select * from virus inner join virus_head using(file_id, file_name) inner join virus_sec using(file_id, file_name) inner join virus_dll using(file_id, file_name)

以下不能去重
inner join on:select * from virus inner join virus_head on virus.file_id=virus_head.file_id and virus.file_name = virus_head.file_name inner join virus_sec on virus.file_id=virus_sec.file_id and virus.file_name = virus_sec.file_name inner join virus_dll on virus.file_id=virus_dll.file_id and virus.file_name = virus_dll.file_name


创建触发器
CREATE TRIGGER newproduct AFTER INSERT ON products FOR EACH ROW SELECT 'Product added';
删除触发器 DROP TRIGGER newproduct;


客户端输出结果到文件
mysql -u xlfv -p featuredb -e "select * from virus natural join virus_head natural join virus_sec natural join virus_dll;" > ~/aa.txt
载入本地文件登录
mysql -u xlfv -p featuredb --local-infile=1 
LOAD DATA LOCAL INFILE '~/aa.txt' INTO TABLE union_virus IGNORE 1 LINES;
删除列
alter table union_virus drop column is_virus;

增加列
alter table union_virus add column is_virus boolean;
update union_virus set is_virus=True;

修改表名
ALTER TABLE union_normal RENAME TO union_all_normal;

从表中随机取出数据
select * from union_all_normal order by rand() limit n;
但这种效率差
优化：
select file_id from union_all_normal AS n1 JOIN (SELECT ROUND(RAND()*(SELECT MAX(file_id) FROM union_all_normal)) AS id) AS n2 WHERE n1.file_id >= n2.id ORDER BY n1.file_id ASC LIMIT 5;


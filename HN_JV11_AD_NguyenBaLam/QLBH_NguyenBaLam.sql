create database QLBH_NGUYENBALAM;
use QLBH_NGUYENBALAM;

create table Customer(
cID int primary key ,
name varchar(25),
cAge tinyint
);

create table `Order`(
oID int primary key ,
cID int,
oDate datetime,
oTotalPrice int,
foreign key (cID) references Customer(cID)
);

create table Product(
pID int primary key ,
pName varchar(25),
pPrice int
);

create table OrderDetail(
oID int,
pID int,
odQTY int,
foreign key (oID) references `Order`(oID),
foreign key (pID) references Product(pID)
);

insert into Customer values
(1,"Minh Quan",10),
(2,"Ngoc Oanh",20),
(3,"Hong Ha",50);

insert into `Order`(oID,cID,oDate) values
(1,1,"2006-3-21"),
(2,2,"2006-3-23"),
(3,1,"2006-3-16");

insert into Product values
(1,"May Giat",3),
(2,"Tu Lanh",5),
(3,"Dieu Hoa",7),
(4,"Quat",1),
(5,"Bep Dien",2);

insert into OrderDetail values
(1,1,3),
(1,3,7),
(1,4,2),
(2,1,1),
(3,1,8),
(2,5,4),
(2,3,3);

-- 2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn
-- trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa
-- đơn mới hơn
select * from `Order` order by oDate desc;
-- 3. Hiển thị tên và giá của các sản phẩm có giá cao nhất
select pName,pPrice from Product where pPrice= (select max(pPrice) from product);
-- 4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản
-- phẩm được mua bởi các khách
select name,p.pName from ((customer c join `Order` o on c.cID=o.cID)
join orderdetail od on od.oID=o.oID)
join product p on p.pID=od.pID;
-- 5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
select name from customer where cID not in (select cID from `order`);
-- 6. Hiển thị chi tiết của từng hóa đơn
select o.oID,o.oDate,od.odQTY,p.pName,p.pPrice from orderdetail od join product p on od.pID=p.pID join `order` o on o.oID=od.oID;
-- 7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một
-- hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện
-- trong hóa đơn. Giá bán của từng loại được tính = odQTY*pPrice)
select o.oID , o.oDate , sum(p.pPrice*od.odQTY) as Total from `order` o 
join orderdetail od on o.oID=od.oID
join product p on p.pID=od.pID group by o.oID;
-- 8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thi
create view Sales as select sum(total) as Sales from (select sum(p.pPrice*od.odQTY) as Total from `order` o 
join orderdetail od on o.oID=od.oID
join product p on p.pID=od.pID group by o.oID) total;
select * from Sales;
-- 9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng.
alter table `order` drop constraint order_ibfk_1;
alter table orderdetail drop constraint orderdetail_ibfk_1;
alter table orderdetail drop constraint orderdetail_ibfk_2;
alter table customer drop primary key;
alter table `Order` drop primary key;
alter table product drop primary key;
-- 10.Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa
-- mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo:
create trigger cusUpdate after update on Customer for each row update `Order` set cID = new.cID where cID = old.cID;
-- test->>
update Customer set cID=10 where cID=2;
-- 11. Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của 
-- một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên 
-- vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong 
-- bảng OrderDetai
DELIMITER //
CREATE PROCEDURE delProduct(in pName varchar(25))
begin
delete from orderdetail where orderdetail.pID=(select product.pID from Product where product.pName=pName);
delete from product where product.pName = pName;
end;
// DELIMITER ;

call delProduct("May Giat");





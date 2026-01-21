drop database if exists final;
create database final;
use final;

create table readers (
    reader_id int primary key auto_increment,
    full_name varchar(100) not null,
    email varchar(100) unique not null,
    phone_number varchar(15),
    created_at date default (current_date)
);


create table membership_details (
    card_number varchar(20) primary key,
    reader_id int unique not null,
    memberrank varchar(20) not null,
    expiry_date date not null,
    citizen_id varchar(20) unique not null,
    foreign key (reader_id) references readers(reader_id)
);

create table categories (
    category_id int primary key auto_increment,
    category_name varchar(50) not null,
    description text
);

create table books (
    book_id int primary key auto_increment,
    title varchar(200) not null,
    author varchar(100) not null,
    category_id int not null,
    price decimal(10,2) check (price > 0),
    stock_quantity int check (stock_quantity >= 0),
    foreign key (category_id) references categories(category_id)
);

create table loan_records (
    loan_id int primary key auto_increment,
    reader_id int not null,
    book_id int not null,
    borrow_date date not null,
    due_date date not null,
    return_date date,
    foreign key (reader_id) references readers(reader_id),
    foreign key (book_id) references books(book_id),
    check (due_date > borrow_date)
);



-- insert du lieu bang readers
insert into readers (reader_id, full_name, email, phone_number, created_at) values
(1, 'Nguyen Van A', 'anv@gmail.com', '901234567', '2022-01-15'),
(2, 'Tran Thi B', 'btt@gmail.com', '912345678', '2022-05-20'),
(3, 'Le Van C', 'cle@yahoo.com', '922334455', '2023-02-10'),
(4, 'Pham Minh D', 'dpham@hotmail.com', '933445566', '2023-11-05'),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '944556677', '2024-01-12');

-- insert du lieu bang membership_details
insert into membership_details (card_number, reader_id, memberrank, expiry_date, citizen_id) values
('CARD-001', 1, 'Standard', '2025-01-15', '123456789'),
('CARD-002', 2, 'VIP', '2025-05-20', '234567890'),
('CARD-003', 3, 'Standard', '2024-02-10', '345678901'),
('CARD-004', 4, 'VIP', '2025-11-05', '456789012'),
('CARD-005', 5, 'Standard', '2026-01-12', '567890123');

-- insert du lieu bang categories
insert into categories (category_id, category_name, description) values
(1, 'IT', 'Sach ve cong nghe thong tin va lap trinh'),
(2, 'Kinh Te', 'Sach kinh doanh, tai chinh, khoi nghiep'),
(3, 'Van Hoc', 'Tieu thuyet, truyen ngan, tho'),
(4, 'Ngoai Ngu', 'Sach hoc tieng Anh, Nhat, Han'),
(5, 'Lich Su', 'Sach nghien cuu lich su, van hoa');

-- insert du lieu bang books
insert into books (book_id, title, author, category_id, price, stock_quantity) values
(1, 'Clean Code', 'Robert C. Martin', 1, 450000, 10),
(2, 'Dac Nhan Tam', 'Dale Carnegie', 2, 150000, 50),
(3, 'Harry Potter 1', 'J.K. Rowling', 3, 250000, 5),
(4, 'IELTS Reading', 'Cambridge', 4, 180000, 0),
(5, 'Dai Viet Su Ky', 'Le Van Huu', 5, 300000, 20);

-- insert du lieu bang loan_records
insert into loan_records (loan_id, reader_id, book_id, borrow_date, due_date, return_date) values
(101, 1, 1, '2023-11-15', '2023-11-22', '2023-11-20'),
(102, 2, 2, '2023-12-01', '2023-12-08', '2023-12-05'),
(103, 1, 3, '2024-01-10', '2024-01-17', null),
(104, 3, 4, '2023-05-20', '2023-05-27', null),
(105, 4, 1, '2024-01-18', '2024-01-25', null);

-- gia han them 7 ngay cho sach van hoc chua tra
update loan_records lr
join books b on lr.book_id = b.book_id
join categories c on b.category_id = c.category_id
set lr.due_date = date_add(lr.due_date, interval 7 day)
where c.category_name = 'Van Hoc' and lr.return_date is null;

-- xoa ho so muon da tra truoc thang 10/2023
delete from loan_records
where return_date is not null and borrow_date < '2023-10-01';



-- cau 1: sach thuoc danh muc IT co gia > 200000
select b.book_id, b.title, b.price
from books b
join categories c on b.category_id = c.category_id
where c.category_name = 'IT' and b.price > 200000;

-- cau 2: doc gia dang ky nam 2022 va email @gmail.com
select reader_id, full_name, email
from readers
where year(created_at) = 2022 and email like '%@gmail.com';

-- cau 3: 5 sach co gia cao nhat (tu cuon thu 3 den thu 7)
select book_id, title, price
from books
order by price desc
limit 5 offset 2;



-- cau 1: thong tin phieu muon chua tra
select 
    lr.loan_id,
    r.full_name,
    b.title,
    lr.borrow_date,
    lr.return_date
from loan_records lr
join readers r on lr.reader_id = r.reader_id
join books b on lr.book_id = b.book_id
where lr.return_date is null;

-- cau 2: tong ton kho theo danh muc (chi hien thi > 10)
select 
    c.category_name,
    sum(b.stock_quantity) as total_stock
from categories c
join books b on c.category_id = b.category_id
group by c.category_id, c.category_name
having sum(b.stock_quantity) > 10;

-- cau 3: doc gia vip chua muon sach > 300000
select distinct r.full_name
from readers r
join membership_details md on r.reader_id = md.reader_id
where md.memberrank = 'VIP'
and r.reader_id not in (
    select distinct lr.reader_id
    from loan_records lr
    join books b on lr.book_id = b.book_id
    where b.price > 300000
);



-- cau 1: composite index tren loan_records
create index idx_loan_dates on loan_records(borrow_date, return_date);

-- cau 2: view hien thi phieu muon qua han
create view vw_overdue_loans as
select 
    lr.loan_id,
    r.full_name,
    b.title,
    lr.borrow_date,
    lr.due_date
from loan_records lr
join readers r on lr.reader_id = r.reader_id
join books b on lr.book_id = b.book_id
where lr.return_date is null and curdate() > lr.due_date;



-- cau 1: trigger giam ton kho khi muon sach
delimiter //
create trigger trg_after_loan_insert
after insert on loan_records
for each row
begin
    update books
    set stock_quantity = stock_quantity - 1
    where book_id = new.book_id;
end//
delimiter ;

-- cau 2: trigger ngan xoa doc gia dang muon sach
delimiter //
create trigger trg_prevent_delete_active_reader
before delete on readers
for each row
begin
    declare loan_count int;
    
    select count(*) into loan_count
    from loan_records
    where reader_id = old.reader_id and return_date is null;
    
    if loan_count > 0 then
        signal sqlstate '45000'
        set message_text = 'Cannot delete reader with active loans';
    end if;
end//
delimiter ;



-- cau 1: procedure kiem tra ton kho
delimiter //
create procedure sp_check_availability(
    in p_book_id int,
    out p_message varchar(50)
)
begin
    declare v_stock int;
    
    select stock_quantity into v_stock
    from books
    where book_id = p_book_id;
    
    if v_stock = 0 then
        set p_message = 'Het hang';
    elseif v_stock > 0 and v_stock <= 5 then
        set p_message = 'Sap het';
    else
        set p_message = 'Con hang';
    end if;
end//
delimiter ;



call sp_check_availability(1, @msg);
select @msg as status;

-- call sp_return_book_transaction(103);
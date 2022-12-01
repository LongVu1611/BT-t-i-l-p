---Câu 1a) Luong trên 15000
CREATE TRIGGER ThemNhanVien  ON NHANVIEN FOR Insert 
AS
IF (select LUONG from inserted) <15000
BEGIN
Print 'luong phải >15000'
ROLLBACK TRANSACTION 
END

INSERT INTO NHANVIEN
VALUES (N'Cổ',N'NGuyệt',N'Thanh','020',cast('1967-10-20' as date),N'230 Lê Văn Sỹ,TP HCM','Nam',14000,'011',4)
----Câu 1b) Ràng buộc khi thêm mới nhân viên thì độ tuổi phải nằm trong khoảng 18 <= tuổi <=65
CREATE TRIGGER check_themnv ON NHANVIEN FOR INSERT AS 
DECLARE @tuoi int
SET @tuoi=year(getdate()) - (SELECT year(NGSINH) FROM inserted)
IF (@tuoi < 18 or @tuoi > 65 )
BEGIN
PRINT 'Yêu cầu nhập tuổi từ 18 đến 65'
ROLLBACK TRANSACTION 
END
GO

INSERT INTO NHANVIEN (HONV,TENLOT,TENNV,MANV,NGSINH,DCHI,PHAI,LUONG,MA_NQL,PHG)
VALUES (N'Lê',N'An',N'Sơn','011',cast('1970-10-20' as date),N'200 Lê Văn Sỹ,TP HCM','Nam',300000,'011',4)

--------Câu 1c)Ràng buộc khi cập nhật nhân viên thì không được cập nhật những nhân viên ở TP HCM
CREATE TRIGGER update_NV ON NHANVIEN FOR update AS
IF (SELECT DCHI FROM inserted ) like '%TP HCM%'
BEGIN
PRINT 'Không thể cập nhật'
ROLLBACK TRANSACTION
END

UPDATE NHANVIEN SET TENNV='Như' where MANV ='001'
--------Câu 2a)Hiển thị tổng số lượng nhân viên nữ, tổng số lượng nhân viên nam mỗi khi có hành động thêm mới nhân viên.
CREATE TRIGGER trg_TongNV
   ON NHANVIEN
   AFTER INSERT
AS
   DECLARE @male int, @female int;
   SELECT @female = count(Manv) from NHANVIEN where PHAI = N'Nữ';
   SELECT @male = count(Manv) from NHANVIEN where PHAI = N'Nam';
   PRINT N'Tổng số nhân viên là nữ: ' + cast(@female as varchar);
   PRINT N'Tổng số nhân viên là nam: ' + cast(@male as varchar);

INSERT INTO NHANVIEN VALUES ('Huỳnh ','Xuân','Tiệp','033','7-12-1999','TP HCM','Nam',60000,'003',1)
GO
--------Câu 2 b) Hiển thị tổng số lượng nhân viên nữ, tổng số lượng nhân viên nam mỗi khi có hành động cập nhật phần giới tính nhân viên
CREATE TRIGGER trg_TongNVSauUpdate
   ON NHANVIEN
   AFTER update
AS
   IF (SELECT TOP 1 PHAI FROM DELETED) != (SELECT TOP 1 PHAI FROM INSERTED)
   BEGIN
      DECLARE @male int, @female int;
      SELECT @female = count(Manv) from NHANVIEN where PHAI = N'Nữ';
      SELECT @male = count(Manv) from NHANVIEN where PHAI = N'Nam';
      PRINT N'Tổng số nhân viên là nữ: ' + cast(@female as varchar);
      PRINT N'Tổng số nhân viên là nam: ' + cast(@male as varchar);
   END;

UPDATE NHANVIEN
   SET HONV = 'Lê',PHAI = N'Nữ'
 WHERE  MaNV = '010'
GO
-------Câu 2c)Hiển thị tổng số lượng đề án mà mỗi nhân viên đã làm khi có hành động xóa trên bảng DEAN
CREATE TRIGGER trg_TongNVSauXoa on DEAN
AFTER DELETE
AS
BEGIN
   SELECT MA_NVIEN, COUNT(MADA) as 'Số đề án đã tham gia' FROM PHANCONG
      GROUP BY MA_NVIEN
END
SELECT * FROM DEAN
INSERT INTO DEAN VALUES ('SQL', 50, 'HH', 4)
DELETE FROM DEAN WHERE MADA=50
-------Câu 3a)Xóa các thân nhân trong bảng thân nhân có liên quan khi thực hiện hành động xóa nhân viên trong bảng nhân viên.
CREATE TRIGGER delete_thannhan on NHANVIEN
INSTEAD OF DELETE
AS
BEGIN
DELETE FROM THANNHAN WHERE MA_NVIEN in(SELECT MANV FROM deleted)
DELETE FROM NHANVIEN WHERE manv in(SELECT MANV FROM deleted)
END
INSERT INTO THANNHAN VALUES ('031', 'Khang', 'Nam', '03-10-2017', 'con')
DELETE NHANVIEN WHERE MANV='031'
------ Câu 3b)Thêm một nhân viên mới thì tự động phân công cho nhân viên làm đề án có MADAlà 1.
CREATE TRIGGER nhanvien3 on NHANVIEN
AFTER INSERT 
AS
BEGIN
INSERT INTO PHANCONG VALUES ((SELECT manv FROM inserted), 1,2,20)
END
INSERT INTO NHANVIEN VALUES ('Huỳnh','Xuân','Tiệp','031','7-12-1999','Hà nội','Nam',60000,'003',1)


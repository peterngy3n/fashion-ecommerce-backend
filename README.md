# Fashion Ecommerce Backend

Backend project sử dụng Express, Prisma, MySQL và Docker.

## Yêu cầu hệ thống

* Docker & Docker Compose
* Node.js (>= 18.x) nếu chạy ngoài Docker
* File dữ liệu MySQL đã export: `mysql-dump.tar`

## 📁 Cấu trúc thư mục

```
.
├── docker-compose.yml
├── Dockerfile
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── src/
├── .env
└── README.md
```

## ⚙️ Thiết lập & chạy

### 1. Load file image database từ .tar

```bash
docker load < mysql-dump.tar
```

### 2. Chạy project

```bash
docker-compose up --build
```

### 3. Generate Prisma Client (nếu cần)

Nếu chưa có thư mục `node_modules`, bạn cần chạy:

```bash
npm install
npx prisma generate
```

## 🔍 Kiểm tra hệ thống

* Express API mặc định chạy tại: `http://localhost:3000`
* Dùng Postman hoặc trình duyệt để test API

## 🧪 Một số lệnh Prisma

```bash
# Migrate nếu thay đổi schema
npx prisma migrate dev

# Studio để xem dữ liệu
npx prisma studio
```



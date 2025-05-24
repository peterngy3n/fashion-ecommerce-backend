# Fashion Ecommerce Backend
## Đặc tả API
- Code yaml đặc tả API nằm ở docs/api.specification.yaml
- Anh/chị vui lòng copy file này vào https://editor.swagger.io/ để xem được đặc tả usecase

Backend project sử dụng Express, Prisma, MySQL và Docker.

## Yêu cầu hệ thống

* Docker & Docker Compose
* Node.js (>= 18.x) nếu chạy ngoài Docker

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

### 1. Load file image database từ .tar (file .tar và .env ở folder Google drive)

```bash
docker load < ecommerce.tar
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



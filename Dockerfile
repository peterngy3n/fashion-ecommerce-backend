# Chọn image Node.js
FROM node:18

# Tạo thư mục làm việc trong container
WORKDIR /app

# Copy các file cần thiết
COPY package.json package-lock.json ./

# Cài đặt dependencies
RUN npm install

# Copy toàn bộ mã nguồn vào container
COPY . .

# Prisma: generate client (nếu dùng)
RUN npx prisma generate

# Mở port container
EXPOSE 3000

# Chạy ứng dụng
CMD ["npm", "run", "start"]

# Base image olarak Node.js LTS sürümünü kullanıyoruz
FROM node:22.14.0 AS builder

# Çalışma dizini oluştur
WORKDIR /app

# Gerekli dosyaları kopyala
COPY package*.json ./

# Bağımlılıkları yükle
RUN yarn install

# Uygulama dosyalarını kopyala
COPY . .

# Nuxt 3 uygulamasını production için build et
RUN yarn build

# Final image için daha küçük bir base image kullanıyoruz
FROM node:18-alpine AS runner

# Çalışma dizini oluştur
WORKDIR /app

# Yalnızca gerekli dosyaları kopyala
COPY --from=builder /app/.output/ ./

# Gerekli portları expose ediyoruz
EXPOSE 3000

# Varsayılan çalışma komutu
CMD ["node", "server/index.mjs"]
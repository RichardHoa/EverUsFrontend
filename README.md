# 💖 EverUs (DateMate)

> **"Advanced Mathematics meets Date Night."**  
> EverUs is a beautiful, interactive couple recommendation app that uses linear algebra matching to find, guide, and save your perfect date experiences.

---

## 🌟 What is EverUs?

EverUs helps you and your partner choose, experience, and remember your date nights. Instead of arguing about what to do, EverUs asks for your preferences (across **5 distinct dimensions**) and matches you with one of **6 highly detailed, custom-tailored date journeys**. 

---

## 🚀 How to Download & Run

### 💻 React Web App

1. **Navigate to the project root and install web dependencies:**
   ```bash
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm run dev
   ```
   Open `http://localhost:5173` in your web browser.

### 📱 Flutter Mobile App

1. **Navigate to the Flutter project folder:**
   ```bash
   cd flutter-project/everus
   ```

2. **Get packages:**
   ```bash
   flutter pub get
   ```

3. **Run the app on your emulator or connected device:**
   ```bash
   flutter run
   ```

---

## ⚙️ Git Commit Template

This repository contains a git commit message template (`.gitmessage`) to maintain uniform commit scopes (`feat:`, `fix:`, `docs:`, `refactor:`, etc.).

To set up this template locally in your clone, run:
```bash
git config commit.template d
```

---

## TODO list

Regarding the thiết kế hẹn hò, we have some big structural change

Let's say the user input 300k for both, then that's 600k for both people, we need to calculate the price in each location so that all the price add up less than 600k, when use search in the API, use the range so the return json includes priceLevel. we would have 3 search for the APi in 3 stages, first filter out all the places that do not have priceLevel, after that filter out all the place that the openingHours do not match the user chosen hour, from the date of the user we can derive the date of the week, and use that to check if the time is suited for the user, and calculate the time, like if the location of the stage one take 1,5 hours, and user start from 4, then for the second location calculate the time to arrive there + 1,5 hours have passed, do not take the 4. 

next, calculate all the possible combinations and their accumulative distance, if the user walk on feet, then be sure choose the combination with the highest rating possible, but prioritize the overall shortest distance, if user use taxi then we can relax the distance a bit, if there is a higher rating combination, if the user is in motorbike then prioritize the rating, but the distance between each locations can be more than 10km.

Since we do not have access to the google API, just calculate the distance using math, but say approx, since this is very approx distance calculating. 

After all of this work, show the plan to the user, the places, their images, but there is one button at the end, if user click this button then it will open gg maps with 3 locations, like we go from first to last location, with the second location being a stop in the middle. 

Almost forget, if the user choose the mood chill, and if the first stage is the cafe, then search for  chill cafe in district (user choice)


search: quán cà phê giá rẻ quận 7

{
  "ll": "@10.7272122,106.717742,14z",
  "places": [
    {
      "position": 1,
      "title": "Aloha Coffee - Quận 7",
      "address": "52 Đ. Số 1, Khu đô thị Him Lam, Tân Hưng, Hồ Chí Minh, Việt Nam",
      "latitude": 10.7391805,
      "longitude": 106.69948049999999,
      "rating": 4.4,
      "ratingCount": 150,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "openingHours": {
        "Thứ Tư": "06:30–15:00",
        "Thứ Năm": "06:30–15:00",
        "Thứ Sáu": "06:30–15:00",
        "Thứ Bảy": "06:30–15:00",
        "Chủ Nhật": "06:30–15:00",
        "Thứ Hai": "06:30–15:00",
        "Thứ Ba": "06:30–15:00"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEhHhg0l8ioJT_QXZfQcd-0Xms2djkqkSplR8eRnHp-x7tDxDoc9G-dXcf3AvP3E1_7iE1-Mx49yG7_D4r0Out38OjIhdNqd46FM2x_AGbrrUxj8V1eEC8_p9QRHivk6PahiH9K",
      "cid": "10651910879951459236",
      "fid": "0x31752fc1d92096d5:0x93d3308252a013a4",
      "placeId": "ChIJ1ZYg2cEvdTERpBOgUoIw05M"
    },
    {
      "position": 2,
      "title": "Bamos Coffee Quận 7 - Cà phê 24h",
      "address": "130 Đ. Số 65, Khu định cư Tân Quy Đông, Tân Hưng, Hồ Chí Minh 700000, Việt Nam",
      "latitude": 10.735802699999999,
      "longitude": 106.70611199999999,
      "rating": 4.2,
      "ratingCount": 1262,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê",
        "Quán cà phê động vật",
        "Không gian làm việc chia sẻ",
        "Quán cà phê internet"
      ],
      "website": "https://bamoscoffee.com/",
      "phoneNumber": "+84 973 878 508",
      "openingHours": {
        "Thứ Tư": "Mở cửa cả ngày",
        "Thứ Năm": "Mở cửa cả ngày",
        "Thứ Sáu": "Mở cửa cả ngày",
        "Thứ Bảy": "Mở cửa cả ngày",
        "Chủ Nhật": "Mở cửa cả ngày",
        "Thứ Hai": "Mở cửa cả ngày",
        "Thứ Ba": "Mở cửa cả ngày"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAESlJGba-80d4lkhmKsrAdxi7o64avIkIZToymzDE0bgaSUg9ji3gameR4ks6QNYbD8h5vpqOG51LpMtIblDESwxKh2GFMs9UCIujwDBOF59Y0c__7_LIskFOl4cd1Uqzl0apw0",
      "cid": "11148006961061331146",
      "fid": "0x31752fcad5504b43:0x9ab5ad4433a480ca",
      "placeId": "ChIJQ0tQ1covdTERyoCkM0SttZo"
    },
    {
      "position": 3,
      "title": "O'hara Coffee- Cafe and Beverage",
      "address": "21 Nguyễn Thị Thập, Tân Mỹ, Hồ Chí Minh, Việt Nam",
      "latitude": 10.737454699999999,
      "longitude": 106.7292535,
      "rating": 4.5,
      "ratingCount": 594,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "https://www.facebook.com/ohara.cafesaloon/",
      "phoneNumber": "+84 28 6298 9734",
      "openingHours": {
        "Thứ Tư": "07:00–23:00",
        "Thứ Năm": "07:00–23:00",
        "Thứ Sáu": "07:00–23:00",
        "Thứ Bảy": "07:00–23:00",
        "Chủ Nhật": "07:00–23:00",
        "Thứ Hai": "07:00–23:00",
        "Thứ Ba": "07:00–23:00"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEd_zccw3YV8XUfpFxd_PMg_dcW2_DycPhYik87ZlqpVDvlTNCvExOnH8Vjj41EkR2IAJqytLICzTV_ovjxFY09KvnadHxgFkn0XebsaCb1aym_aX7tiuhGZQUCb_5TXVG1eNrbag",
      "cid": "10500147719188729014",
      "fid": "0x3175257c0bdd986d:0x91b804b7eb5f4cb6",
      "placeId": "ChIJbZjdC3wldTERtkxf67cEuJE"
    },
    {
      "position": 4,
      "title": "HERA COFFEE AND TEA | CÀ PHÊ NGON QUẬN 7 | CÀ PHÊ VIEW ĐẸP QUẬN 7",
      "address": "852 Huỳnh Tấn Phát, Tân Mỹ, Hồ Chí Minh, Việt Nam",
      "latitude": 10.729047999999999,
      "longitude": 106.7324469,
      "rating": 4.3,
      "ratingCount": 48,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "phoneNumber": "+84 773 613 365",
      "openingHours": {
        "Thứ Tư": "07:00–23:00",
        "Thứ Năm": "07:00–23:00",
        "Thứ Sáu": "07:00–23:00",
        "Thứ Bảy": "07:00–23:30",
        "Chủ Nhật": "07:00–23:30",
        "Thứ Hai": "07:00–23:00",
        "Thứ Ba": "07:00–23:00"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAHfMLQo5A46xMR2MBufEuaULMouujYIP5J7VE18gejm-I4etWY_DnWCq4FrZpCMUf87YB9lS--pf9HzDgWy7xIxCevREIbxQmkAPZBYHj-fvnCWzwPvVtDV4t2llvoYVUhFv6bNIw",
      "cid": "11003861365670455069",
      "fid": "0x31752579819570e5:0x98b5919c726ea71d",
      "placeId": "ChIJ5XCVgXkldTERHaducpyRtZg"
    },
    {
      "position": 5,
      "title": "LỀ CAFÉ",
      "address": "98 Nguyễn Thị Thập, Khu đô thị Him Lam, Tân Hưng, Hồ Chí Minh 70000, Việt Nam",
      "latitude": 10.741608,
      "longitude": 106.6950148,
      "rating": 4.2,
      "ratingCount": 707,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "https://www.facebook.com/people/L%E1%BB%81-Caf%C3%A9/61567247172628/",
      "phoneNumber": "+84 398 017 140",
      "openingHours": {
        "Thứ Tư": "Mở cửa cả ngày",
        "Thứ Năm": "Mở cửa cả ngày",
        "Thứ Sáu": "Mở cửa cả ngày",
        "Thứ Bảy": "Mở cửa cả ngày",
        "Chủ Nhật": "Mở cửa cả ngày",
        "Thứ Hai": "Mở cửa cả ngày",
        "Thứ Ba": "Mở cửa cả ngày"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAGMFMnAwBwbCrNmgbXxByFTA1kB4oRlTvcrY_LmHg3hKF-zUuFW50TUQGQrTSgj7i9hX63PBqigMuL2oJnsHOCRd-UDKB5nQriNEUJtcYVVLXQWaOEGvGR5-iKTMqbBaqC0COI0C33iYVM",
      "cid": "11463672574251712183",
      "fid": "0x31752f70e6487315:0x9f17257819a93eb7",
      "placeId": "ChIJFXNI5nAvdTERtz6pGXglF58"
    },
    {
      "position": 6,
      "title": "Bamos Coffee Quận 7 - Cà phê 24h (Khu Kim Sơn)",
      "address": "B68 Đ. Số 3, Khu dân cư Kim Sơn, Tân Hưng, Hồ Chí Minh 70000, Việt Nam",
      "latitude": 10.734841999999999,
      "longitude": 106.7007331,
      "rating": 4.6,
      "ratingCount": 771,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "http://bamoscoffee.com/",
      "phoneNumber": "+84 973 878 508",
      "openingHours": {
        "Thứ Tư": "Mở cửa cả ngày",
        "Thứ Năm": "Mở cửa cả ngày",
        "Thứ Sáu": "Mở cửa cả ngày",
        "Thứ Bảy": "Mở cửa cả ngày",
        "Chủ Nhật": "Mở cửa cả ngày",
        "Thứ Hai": "Mở cửa cả ngày",
        "Thứ Ba": "Mở cửa cả ngày"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAENCPUfzMYZpUB_ck9YCzLhe8EI4d4pCFRiN7FsU1PhgfQ5DaJEPg_a_dGazv7dilUFFe4M621GghK7xfb1XxLAwGt0tzO80Zg-yklHmzByMEQWKf0bdZSNeqUXpecRfGbqiyN5",
      "cid": "3613202543359710568",
      "fid": "0x31752f72ce74dad9:0x3224ac91d27e5568",
      "placeId": "ChIJ2dp0znIvdTERaFV-0pGsJDI"
    },
    {
      "position": 7,
      "title": "Mây Farm Quận 7",
      "address": "77/50/9 Đường Chuyên Dùng Chính, Phú Thuận, Hồ Chí Minh 700000, Việt Nam",
      "latitude": 10.70772,
      "longitude": 106.74046919999999,
      "rating": 4.5,
      "ratingCount": 1188,
      "priceLevel": "100-200 N ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "phoneNumber": "+84 588 282 828",
      "openingHours": {
        "Thứ Tư": "07:30–18:00",
        "Thứ Năm": "07:30–18:00",
        "Thứ Sáu": "07:30–22:00",
        "Thứ Bảy": "07:30–22:00",
        "Chủ Nhật": "07:30–22:00",
        "Thứ Hai": "07:30–18:00",
        "Thứ Ba": "07:30–18:00"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAE95qXWWZB1gnhj4tKeXd5A4ZYePilRffc3Z24ImTWWVTSjw2uoldxEByOVGFdr0RVBqJD-IMHT5Vfg99dPrQESmvbn-xKec2ot9hWnDWvSViHSL0tMY_TXJpBpPp_43bfuHiz6gbkWHaE",
      "cid": "6558116251433464150",
      "fid": "0x3175252cae709e1b:0x5b031bfbfa687156",
      "placeId": "ChIJG55wriwldTERVnFo-vsbA1s"
    },
    {
      "position": 8,
      "title": "O’renchi Cafe",
      "address": "501 Lê Văn Lương, Tân Hưng, Hồ Chí Minh, Việt Nam",
      "latitude": 10.7358491,
      "longitude": 106.70285009999999,
      "rating": 4.6,
      "ratingCount": 199,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "https://instagram.com/orenchicafe_sgn?igshid=MzRlODBiNWFlZA==",
      "phoneNumber": "+84 903 995 618",
      "openingHours": {
        "Thứ Tư": "08:00–22:00",
        "Thứ Năm": "08:00–22:00",
        "Thứ Sáu": "08:00–22:00",
        "Thứ Bảy": "08:00–22:00",
        "Chủ Nhật": "08:00–22:00",
        "Thứ Hai": "08:00–22:00",
        "Thứ Ba": "08:00–22:00"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAF6NGmk1QdX7yD7DTwhI25RO7BpU6AVcYjODtw1nbQmJlgkvvqIUclnO0sC9pePyU9lYGvAxzK_0PlPmhIAZGbs65nx0bgeCtB0BZQkFftiqRMtKNUyj1FR09TshLmz7NDHNkerHA",
      "cid": "10570984485108124651",
      "fid": "0x31752f20d05ee9bd:0x92b3ae61b9090beb",
      "placeId": "ChIJvele0CAvdTER6wsJuWGus5I"
    },
    {
      "position": 9,
      "title": "Neru Coffee 24/7 chi nhánh quận 7",
      "address": "4 Đ. Số 1, Tân Mỹ, Hồ Chí Minh, Việt Nam",
      "latitude": 10.7369107,
      "longitude": 106.7212125,
      "rating": 3.3,
      "ratingCount": 165,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "https://nerucoffee.com/",
      "phoneNumber": "+84 969 458 881",
      "openingHours": {
        "Thứ Tư": "Mở cửa cả ngày",
        "Thứ Năm": "Mở cửa cả ngày",
        "Thứ Sáu": "Mở cửa cả ngày",
        "Thứ Bảy": "Mở cửa cả ngày",
        "Chủ Nhật": "Mở cửa cả ngày",
        "Thứ Hai": "Mở cửa cả ngày",
        "Thứ Ba": "Mở cửa cả ngày"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEzAchleIbA1uqsu598GXPssXTlvnzuFEilkJGhXxAi-LKpixnclSC0N1M_NzA2XWvAp-YtmoIdu0nHCDY6AXn0goYvMKlMmmh35Bbah1vPz3fuD0tz1nDOwduBO3Ec66E5eJ9o3EXCJ4w",
      "cid": "11828253108389133980",
      "fid": "0x317525002ee29263:0xa426658886f1be9c",
      "placeId": "ChIJY5LiLgAldTERnL7xhohlJqQ"
    },
    {
      "position": 10,
      "title": "Tiệm Cà Phê Tuệ",
      "address": "Hẻm vào nhà hàng Maison, 793/57/3 Trần Xuân Soạn, KP4, KDC Kiều Đàm, Tân Hưng, Hồ Chí Minh, Việt Nam",
      "latitude": 10.7467043,
      "longitude": 106.700386,
      "rating": 4.5,
      "ratingCount": 203,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "phoneNumber": "+84 945 432 979",
      "openingHours": {
        "Thứ Tư": "Mở cửa cả ngày",
        "Thứ Năm": "Mở cửa cả ngày",
        "Thứ Sáu": "Mở cửa cả ngày",
        "Thứ Bảy": "Mở cửa cả ngày",
        "Chủ Nhật": "Mở cửa cả ngày",
        "Thứ Hai": "Mở cửa cả ngày",
        "Thứ Ba": "Mở cửa cả ngày"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAGC6b3ZvlabVPrSI4gUGaDhgMmgIRKUgXaJ4tdrt3eZoDBVouVApwkO5qbiMJQJgjWjOI1vaWADefYpEk5Hb7jCV9tTyKOZdRpE6NVLx9ISalXAitIHiL2cPRZFaCr_MzzwGbRL",
      "cid": "10789181304755072904",
      "fid": "0x31752faa15a8dccf:0x95badf3baf362f88",
      "placeId": "ChIJz9yoFaovdTERiC82rzvfupU"
    },
    {
      "position": 11,
      "title": "Âme Café & Brunch - The Panorama",
      "address": "The Panorama, 28 Đường P, Khu đô thị Phú Mỹ Hưng, Tân Hưng, Hồ Chí Minh 70000, Việt Nam",
      "latitude": 10.7217913,
      "longitude": 106.71451119999999,
      "rating": 4.6,
      "ratingCount": 246,
      "priceLevel": "100-200 N ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "https://www.facebook.com/amecafenbrunch",
      "phoneNumber": "+84 522 366 399",
      "openingHours": {
        "Thứ Tư": "07:00–21:30",
        "Thứ Năm": "07:00–21:30",
        "Thứ Sáu": "07:00–21:30",
        "Thứ Bảy": "07:00–22:30",
        "Chủ Nhật": "07:00–22:30",
        "Thứ Hai": "07:00–21:30",
        "Thứ Ba": "07:00–21:30"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAF7MvEtzGc-ZDdJKVDtyPV4kwf3hw8bPPSWYY3DY7-7H3nkt9jTUGi56N5J8UwKGV-cinFRLB-s2aYZPYokMxjNA-nn6tk-HnA7cV-SY29NBX67vL0XadAOe0hAPBE82bRdKVoVFw",
      "cid": "1294381021782138987",
      "fid": "0x31752f6e56535f4d:0x11f690ae6f54e06b",
      "placeId": "ChIJTV9TVm4vdTERa-BUb66Q9hE"
    },
    {
      "position": 12,
      "title": "YOON Coffee",
      "address": "94 Đ. số 9, Quận 7, Hồ Chí Minh, Việt Nam",
      "latitude": 10.7360727,
      "longitude": 106.7177888,
      "rating": 4.6,
      "ratingCount": 172,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "website": "https://www.facebook.com/share/14YbTPSex1F/?mibextid=wwXIfr",
      "phoneNumber": "+84 988 551 119",
      "openingHours": {
        "Thứ Tư": "07:00–22:00",
        "Thứ Năm": "07:00–22:00",
        "Thứ Sáu": "07:00–22:00",
        "Thứ Bảy": "07:00–22:00",
        "Chủ Nhật": "07:00–22:00",
        "Thứ Hai": "07:00–22:00",
        "Thứ Ba": "07:00–22:00"
      },
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAGXzEUKftssK2sHo8mOuuURi3j4LqIcaswB0bX4MYq3aQIexc1PojRkYuJ-312llk1fxxsu6IOjTGc9Uxv5xg5d7icQMDvSqLnVENzqfBM9lBrT7FdhLKi-ASzZa-Ia3s7NZGI5",
      "cid": "8742483776598401176",
      "fid": "0x31752f003f15993d:0x79538aacd6c36098",
      "placeId": "ChIJPZkVPwAvdTERmGDD1qyKU3k"
    },
    {
      "position": 13,
      "title": "Nắng Rooftop Coffee Quận 7",
      "address": "326 Lê Văn Lương, Tân Hưng, Hồ Chí Minh 700000, Việt Nam",
      "latitude": 10.7410994,
      "longitude": 106.70346959999999,
      "rating": 4.7,
      "ratingCount": 1037,
      "priceLevel": "1-100.000 ₫",
      "type": "Quán cà phê",
      "types": [
        "Quán cà phê"
      ],
      "thumbnailUrl": "https://lh3.googleusercontent.com/gps-cs-s/APNQkAFLHPhieLJmxISy8BLLrBx7ypwQxne6c9YS35RSrWdKqyAaCo-4sQs6aSUvxdORFzK2SPtESmRrE8CynFT5CA-xpeRWbrQWiFDKSHHCHnmeGuZC33MxAZOh5eF7y_RF83whSvJMrA",
      "cid": "6430673105343283098",
      "fid": "0x31752ff4b2c2f48f:0x593e571e3ea4ff9a",
      "placeId": "ChIJj_TCsvQvdTERmv-kPh5XPlk"
    }
  ],
  "credits": 3
}
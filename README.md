# Korean Ramen Guide - Netlify Deployment

> **Bonus:** this repo also contains **Lords of Chaos — Wizard Duel**, a mobile-friendly
> turn-based wizard battle game inspired by Julian Gollop's 1990 classic.
> It lives at [`lords-of-chaos/index.html`](lords-of-chaos/index.html) — a single
> self-contained file with no dependencies. If deployed to Netlify along with the
> site, it's playable at `/lords-of-chaos/` on any phone browser.

A two-page affiliate marketing site for Korean ramen seasoning ingredients and recipe guide.

## 📁 Files Included

- `index.html` - Shopping list page (affiliate links)
- `guide.html` - Guide sales page (Etsy)
- `styles.css` - Complete styling for both pages
- `script.js` - Filter functionality
- `README.md` - This file

## 🚀 Deploy to Netlify

### Method 1: Drag & Drop (Easiest)

1. Go to [app.netlify.com](https://app.netlify.com)
2. Sign up or log in
3. Drag the entire folder into the deploy box
4. Done! Your site is live

### Method 2: GitHub + Netlify (Professional)

1. Create a new GitHub repository
2. Upload all files to the repo
3. Connect your repo to Netlify:
   - Go to app.netlify.com
   - Click "New site from Git"
   - Choose GitHub
   - Select your repository
   - Click "Deploy site"
4. Auto-deploys whenever you push changes

## ⚙️ Configuration Needed

### 1. Update Affiliate Links

Replace all `#` placeholders in `index.html` with your Amazon affiliate links:

```html
<!-- Find and replace these: -->
<a href="#" class="btn btn-primary btn-affiliate" target="_blank" rel="nofollow">
<!-- With your actual Amazon links: -->
<a href="https://amazon.com/your-affiliate-link" class="btn btn-primary btn-affiliate" target="_blank" rel="nofollow">
```

**Products to link (16 total):**
1. Korean Gochugaru
2. Garlic Powder
3. Onion Powder
4. MSG (Ac'cent)
5. Soy Sauce Powder
6. Beef Stock Powder
7. Ginger Powder
8. Toasted Sesame Oil
9. Shiitake Mushroom Powder
10. Anchovy/Bonito Powder
11. Citric Acid
12. Chili Oil
13. Glass Spice Jars
14. Digital Kitchen Scale
15. Electric Spice Grinder
16. Silica Gel Desiccant Packs

### 2. Update Etsy Shop Link

Replace the Etsy placeholder in `guide.html`:

```html
<!-- Find: -->
https://www.etsy.com/shop/YourShop
<!-- Replace with: -->
https://www.etsy.com/shop/YourActualShopName
```

**Or use Gumroad/Payhip/Other:**
```html
https://yourname.gumroad.com/l/korean-ramen-guide
```

### 3. Add Patreon Link

Update footer links in both files:

```html
<a href="#" target="_blank">Join on Patreon</a>
<!-- Change to: -->
<a href="https://www.patreon.com/yourusername" target="_blank">Join on Patreon</a>
```

## 🔧 Customization Options

### Change Colors

Edit `styles.css`:

```css
:root {
    --red: #D32F2F;     /* Primary brand color */
    --orange: #FF6F00;  /* Accent color */
    --dark: #212121;    /* Text color */
}
```

### Change Site Name

Update the logo in both HTML files:

```html
<div class="logo">
    <h1>🌶️ Korean Ramen Guide</h1>
</div>
```

### Add Google Analytics

Add before `</head>` in both HTML files:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=YOUR-GA-ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'YOUR-GA-ID');
</script>
```

## 📱 Custom Domain Setup

1. Buy a domain (Namecheap, Google Domains, etc.)
2. In Netlify: Site settings → Domain management → Add custom domain
3. Update DNS records as instructed by Netlify
4. SSL certificate auto-generated (free HTTPS)

**Suggested domains:**
- koreanramenguide.com
- diykoreanramen.com
- ramenspicekit.com

## ✅ Pre-Launch Checklist

- [ ] Replace all affiliate links with your Amazon Associates links
- [ ] Update Etsy shop URL (or other sales platform)
- [ ] Add your Patreon link
- [ ] Test all buttons and links
- [ ] Check mobile responsiveness
- [ ] Add Google Analytics (optional)
- [ ] Set up custom domain (optional)
- [ ] Add favicon (optional)
- [ ] Test on different browsers

## 🎯 SEO Tips

### Add to `<head>` sections:

```html
<!-- Open Graph for social sharing -->
<meta property="og:title" content="Korean Ramen Seasoning Guide">
<meta property="og:description" content="Complete ingredient shopping list and recipe guide">
<meta property="og:image" content="https://yoursite.com/preview.jpg">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Korean Ramen Seasoning Guide">
<meta name="twitter:description" content="Make authentic Korean ramen at home">
```

### Create sitemap.xml:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://yoursite.com/index.html</loc>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://yoursite.com/guide.html</loc>
    <priority>0.8</priority>
  </url>
</urlset>
```

## 💰 Monetization Strategy

### Page 1 (Shopping List):
- **Revenue:** Amazon affiliate commissions (1-4%)
- **Traffic:** Pinterest, Instagram, Google search
- **Goal:** 30-50% click-through to Amazon

### Page 2 (Guide):
- **Revenue:** PDF sales ($7.99)
- **Traffic:** From shopping list page
- **Goal:** 10-20% conversion rate

### Combined Revenue Example:
- 1,000 visitors/month
- 400 click to Amazon (40%)
- 20 Amazon purchases = $40-80 commission
- 100 visit guide page (10%)
- 20 buy PDF (20%) = $160
- **Total: ~$200-240/month**

## 📊 Analytics to Track

1. **Traffic sources** (Pinterest, Instagram, Google)
2. **Page views** (Shopping list vs Guide)
3. **Amazon click-through rate**
4. **Guide page conversion rate**
5. **Average order value** (Amazon)

## 🆘 Support

- **Netlify Docs:** https://docs.netlify.com
- **Amazon Associates:** https://affiliate-program.amazon.com
- **Web hosting issues:** Check Netlify status or forums

## 📝 License

This is a template. Customize and use for your own projects.

---

**Ready to deploy?** Just drag the folder to Netlify and start earning! 🚀

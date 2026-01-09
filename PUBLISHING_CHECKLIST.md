# Google Play Publishing Checklist

Quick reference checklist for publishing Laapak app to Google Play Store.

## 📋 Pre-Publishing Checklist

### Account Setup
- [ ] Google Play Developer account created ($25 fee paid)
- [ ] Developer profile completed
- [ ] Payment method configured (if selling paid apps)

### App Bundle
- [ ] App bundle built: `flutter build appbundle --release`
- [ ] App bundle location: `build/app/outputs/bundle/release/app-release.aab`
- [ ] App bundle size: Check (should be reasonable, max 150MB)
- [ ] Version code and name set in `pubspec.yaml`: `1.0.0+1`

### Privacy Policy
- [ ] Privacy policy HTML file created: `PRIVACY_POLICY.html`
- [ ] Privacy policy uploaded to website
- [ ] Privacy policy URL accessible via HTTPS
- [ ] Contact information added to privacy policy
- [ ] Privacy policy URL tested in browser

### Assets Required
- [ ] **App Icon:** 512 x 512 pixels, PNG with alpha, max 1024 KB
- [ ] **Feature Graphic:** 1024 x 500 pixels, PNG/JPG, max 15 MB
- [ ] **Phone Screenshots:** 2-8 images, 16:9 or 9:16 ratio
- [ ] **Tablet Screenshots:** Optional but recommended

### Store Listing Content
- [ ] App name: "Laapak" (max 50 chars)
- [ ] Short description: Written (max 80 chars)
- [ ] Full description: Written (80-4000 chars)
- [ ] Screenshots: Uploaded
- [ ] Graphics: Uploaded
- [ ] Category: Selected (Tools or Business)
- [ ] Contact email: Added
- [ ] Contact phone: Added (optional)
- [ ] Website: https://laapak.com

### App Content & Policies
- [ ] Content rating questionnaire completed
- [ ] Content rating certificate obtained
- [ ] Data safety form completed
- [ ] Target audience selected
- [ ] App access restrictions set (if needed)

### Distribution Settings
- [ ] Countries/regions selected
- [ ] Pricing set (Free or Paid)
- [ ] Device categories selected (Phones, Tablets)
- [ ] Content guidelines acknowledged
- [ ] Export compliance confirmed

## 🚀 Publishing Steps

1. [ ] Create app in Google Play Console
2. [ ] Complete store listing
3. [ ] Upload app bundle
4. [ ] Add release notes
5. [ ] Complete content rating
6. [ ] Complete data safety form
7. [ ] Review all information
8. [ ] Submit for review
9. [ ] Monitor review status

## 📝 Post-Publishing

- [ ] Monitor app status
- [ ] Respond to user reviews
- [ ] Track analytics
- [ ] Plan updates

## 🔗 Important Links

- Privacy Policy: Update `PRIVACY_POLICY.html` with your contact info
- App Website: https://laapak.com
- Publishing Guide: See `GOOGLE_PLAY_PUBLISHING_GUIDE.md`

## ⚠️ Important Notes

1. **Privacy Policy URL is REQUIRED** - Must be publicly accessible via HTTPS
2. **First review takes 1-7 days** - Be patient
3. **Version code must always increase** - Cannot reuse version codes
4. **Keep privacy policy updated** - Must reflect actual app behavior
5. **Test thoroughly** - Before each release

## 📞 Contact Information

Contact information has been configured:
```
Email: support@laapak.com
Phone/WhatsApp: 01013148007
Website: https://laapak.com
```

---

**Ready to publish?** Follow `GOOGLE_PLAY_PUBLISHING_GUIDE.md` for detailed steps.


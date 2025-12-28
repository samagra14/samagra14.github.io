# How to Enable Auto-Posting to Social Media

This guide explains how to get the necessary API keys for X (Twitter), LinkedIn, and Reddit, and how to set them up in your GitHub repository to enable automated posting when you publish a new blog post.

## 1. Get API Keys

### 🐦 X (Twitter)
*Note: You need a Developer Account. The free tier allows 1,500 posts/month.*
1.  Go to the [X Developer Portal](https://developer.twitter.com/en/portal/dashboard).
2.  Sign up for a **Free** developer account if you haven't already.
3.  Create a new **Project** and **App**.
4.  Navigate to **Keys and Tokens**.
5.  Generate the following and **save them immediately**:
    *   `API Key` (Consumer Key)
    *   `API Key Secret` (Consumer Secret)
    *   `Access Token`
    *   `Access Token Secret`
6.  **Important**: Ensure your App has **Read and Write** permissions. Go to "User authentication settings", enable OAuth 1.0a, and switch permissions to "Read and Write". Regenerate tokens if you change permissions.

### 💼 LinkedIn
1.  Go to [LinkedIn Developers](https://www.linkedin.com/developers/apps).
2.  Click **Create App**. Associate it with your Company Page (or create a dummy one if posting to personal profile basically works via the same API, but officially usually requires a page context for easiest automation).
3.  Under the **Products** tab, request access to **Share on LinkedIn** (or *Sign In with LinkedIn* + *Share on LinkedIn*).
4.  Go to **Auth** tab.
5.  Note down:
    *   `Client ID`
    *   `Client Secret`
6.  *Token Note*: LinkedIn Access Tokens expire (usually 60 days). For mostly hands-off automation, you might need a workflow that refreshes them, or manually update the secret every 2 months. 

### 🤖 Reddit
1.  Go to [Reddit App Preferences](https://www.reddit.com/prefs/apps).
2.  Click **Create another app...** (bottom of page).
3.  Select **script**.
4.  Fill in details (redirect uri can be `http://localhost:8080`).
5.  Click **create app**.
6.  Note down:
    *   `Client ID` (the string under the app name)
    *   `Client Secret`
    *   `Username` (your reddit username)
    *   `Password` (your reddit password)

## 2. Add Secrets to GitHub

1.  Go to your GitHub Repository.
2.  Click **Settings** > **Secrets and variables** > **Actions**.
3.  Click **New repository secret**.
4.  Add the following secrets matching your keys:

    **Twitter:**
    *   `TWITTER_CONSUMER_KEY`
    *   `TWITTER_CONSUMER_SECRET`
    *   `TWITTER_ACCESS_TOKEN`
    *   `TWITTER_ACCESS_TOKEN_SECRET`

    **LinkedIn:**
    *   `LINKEDIN_ACCESS_TOKEN` (You need to generate this using your Client ID/Secret via a tool like Postman standard OAuth2 flow, or use a specific GitHub Action that simplifies this).

    **Reddit:**
    *   `REDDIT_CLIENT_ID`
    *   `REDDIT_CLIENT_SECRET`
    *   `REDDIT_USERNAME`
    *   `REDDIT_PASSWORD`
    *   `REDDIT_SUBREDDIT` (Target subreddit, e.g., `technology` or your own profile `u_yourname`)

## 3. Enable the Workflow
Once the secrets are added, uncomment the relevant sections in `.github/workflows/distribute.yml`.

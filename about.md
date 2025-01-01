# FireBased Blog - Mobile Edition!
## Programmed by Joshua Lee

## Introduction
FireBased Blog is back with a new mobile edition for greater convenience to our users! We have all the basics from the web version of FireBased Blog plus some new editions. So let's run down the features, shall we?

## Features
### Delete
Ever write something you wished you didn't? Ever cringed at a post that is now up forever? Well with the delete feature, you can get rid of all your terrible posts and no one will be any the wiser! Of course, you can always replace those thoughts with ...

### Edit
When you click an article, to the right of the Delete button will be an edit button that allows you to change the title and body text of the article, making it a whole new thing! Takes the hassle out of deleting and creating a whole new article.

### Search
At some point, you might have written too any articles and have no way to sort through them, but now you do! With our new search feature, users will be able to comb through their articles and find the one that they're looking for in a cinch!

### Google Authentication
As always, users will need to sign in with an email and password. However, FireBased Blog Mobile also supports Google authentication as well, meaning you can sign in with your Google accounts and connect your FireBased Blog Mobile account with it!

Here are our security rules:
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true 
      allow write: if request.auth != null;
    }
  }
}

It allows anyone to view others' articles, but they must sign in to create their own articles.

### So go out there and post to your heart's content!

# AWS S3 Static Website Hosting - Øvelse

## Mål
I denne øvelsen skal du lære å:
- Konfigurere AWS CLI i GitHub Codespaces
- Opprette en S3 bucket
- Konfigurere bucket for static website hosting
- Deploye statiske filer til S3

## Forutsetninger
- GitHub konto med Codespaces tilgang
- AWS konto med IAM bruker og access keys

## Del 1: Konfigurer AWS CLI i Codespaces

### Steg 1: Start Codespaces
1. Fork dette repoet til din GitHub konto
2. Åpne repoet i GitHub Codespaces ved å klikke på "Code" → "Codespaces" → "Create codespace on main"

### Steg 2: Installer AWS CLI (hvis ikke installert)
Sjekk først om AWS CLI er installert:
```bash
aws --version
```

Hvis AWS CLI ikke er installert, installer det med:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Steg 3: Konfigurer AWS credentials

Følg veiledningen her https://github.com/glennbechdevops/aws-iam-accesskeys for å lage de nødvendige tilgangsnøklene 

```bash
aws configure
```

Du vil bli bedt om å oppgi:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (f.eks. `eu-north-1`)
- Default output format (trykk Enter for default)

**Sikkerhetstips:** Aldri commit AWS credentials til Git!

## Del 2: Opprett og konfigurer S3 Bucket

### Steg 1: Opprett en S3 bucket
Velg et unikt bucket-navn (må være globalt unikt):
```bash
BUCKET_NAME="mitt-nettsted-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region eu-north-1
```

### Steg 2: Konfigurer bucket policy for offentlig tilgang
Opprett en fil `bucket-policy.json`:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::BUCKET_NAME/*"
        }
    ]
}
```

NB! Erstatt `BUCKET_NAME` med ditt faktiske bucket-navn 

```bash

# Fjern block public access (nødvendig for offentlig website)
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Apply bucket policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json
```

### Steg 3: Aktiver static website hosting
```bash
aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document error.html
```

## Del 3: Deploy statiske filer

### Steg 1: Opprett eksempel HTML filer
Lag en mappe `website` med følgende filer:

**website/index.html:**
```html
<!DOCTYPE html>
<html lang="no">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Min S3 Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Velkommen til min S3-hostede nettside!</h1>
        <p>Dette er en statisk nettside hostet på Amazon S3.</p>
        <p>Deployed fra GitHub Codespaces med AWS CLI 🚀</p>
    </div>
</body>
</html>
```

**website/style.css:**
```css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.container {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    max-width: 600px;
    text-align: center;
}

h1 {
    color: #333;
    margin-bottom: 1rem;
}

p {
    color: #666;
    line-height: 1.6;
}
```

**website/error.html:**
```html
<!DOCTYPE html>
<html lang="no">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Side ikke funnet</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>404 - Side ikke funnet</h1>
        <p>Beklager, siden du leter etter finnes ikke.</p>
        <a href="/">Tilbake til forsiden</a>
    </div>
</body>
</html>
```

### Steg 2: Synkroniser filer til S3
```bash
aws s3 sync website/ s3://$BUCKET_NAME/ --delete
```

Parameteren `--delete` sørger for at filer som er slettet lokalt også slettes fra S3.

### Steg 3: Få URL til nettstedet
```bash
echo "Nettstedet er tilgjengelig på:"
echo "http://$BUCKET_NAME.s3-website-eu-north-1.amazonaws.com"
```

## Del 4: Oppdater og redeploy

### Gjør endringer og sync på nytt
1. Rediger HTML/CSS filene i `website/` mappen
2. Kjør sync kommandoen på nytt:
```bash
aws s3 sync website/ s3://$BUCKET_NAME/ --delete
```

### 1. Legg til JavaScript interaktivitet
Lag en `website/script.js` fil og legg til interaktiv funksjonalitet. Kan du lage et enkelt react prosjekt?

## Ressurser
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CLI S3 Commands](https://docs.aws.amazon.com/cli/latest/reference/s3/)
- [S3 Static Website Hosting Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

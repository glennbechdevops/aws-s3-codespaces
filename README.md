# AWS S3 Static Website Hosting - Øvelse

## Mål
I denne øvelsen skal du lære å:
- Konfigurere AWS CLI i GitHub Codespaces
- Opprette en S3 bucket
- Konfigurere bucket for static website hosting
- Deploye statiske filer til S3

I denne oppgaven skal vi også lære å bruke AWS CLI (aws kommandolinje) og bli kjent med terminalen. Det er fint om du prøver å forstå hva hver enkelt kommando gjør, men det aller viktigste er:

* At du får tilgang til klassens AWS-miljø
* At du får tilgang til AWS fra terminalen i Codespaces

## Forutsetninger
- GitHub konto med Codespaces tilgang
- AWS konto med IAM bruker og access keys, følg veiledning her ; https://github.com/glennbechdevops/aws-iam-accesskeys

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
Du kan *for eksempel* gjøre det slik, men velg gjerne et kreativt navn på din bucket. 

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

Erstatt `BUCKET_NAME` med ditt faktiske bucket-navn og apply policy:
```bash
# Erstatt BUCKET_NAME i policy filen
sed -i "s/BUCKET_NAME/$BUCKET_NAME/g" bucket-policy.json

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

Det ligger HTML kode for en veldig enkel website i `/website` katalogen

### Steg 1: Synkroniser filer til S3
```bash
aws s3 sync website/ s3://$BUCKET_NAME/ --delete
```

Parameteren `--delete` sørger for at filer som er slettet lokalt også slettes fra S3.

### Steg 3: Få URL til nettstedet
```bash
echo "Nettstedet er tilgjengelig på:"
echo "http://$BUCKET_NAME.s3-website.eu-north-1.amazonaws.com"
```

## Del 4: Oppdater og redeploy

### Gjør endringer og sync på nytt
1. Rediger HTML/CSS filene i `website/` mappen
2. Kjør sync kommandoen på nytt:
```bash
aws s3 sync website/ s3://$BUCKET_NAME/ --delete
```

### Overvåk filer i bucketen
```bash
aws s3 ls s3://$BUCKET_NAME/ --recursive
```

## Bonusoppgaver

### 1. Legg til JavaScript interaktivitet
Lag en `website/script.js` fil og legg til interaktiv funksjonalitet.

### 2. Automatiser deployment med et bash script
Lag et script `deploy.sh` som automatiserer hele prosessen:
```bash
#!/bin/bash
BUCKET_NAME=${1:-"mitt-nettsted-$(date +%s)"}

echo "Deploying to bucket: $BUCKET_NAME"

# Sjekk om bucket eksisterer
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'
then
    echo "Creating bucket..."
    aws s3 mb s3://$BUCKET_NAME --region eu-north-1
    
    # Konfigurer bucket
    # ... (legg til policy og website config her)
fi

# Sync filer
aws s3 sync website/ s3://$BUCKET_NAME/ --delete

echo "Deploy complete!"
echo "URL: http://$BUCKET_NAME.s3-website-eu-north-1.amazonaws.com"
```

### 3. Legg til CloudFront CDN
Konfigurer CloudFront distribusjon foran S3 bucketen for bedre ytelse.

## Opprydding
Når du er ferdig med øvelsen, slett bucketen for å unngå kostnader:
```bash
# Tøm bucketen først
aws s3 rm s3://$BUCKET_NAME --recursive

# Slett bucketen
aws s3 rb s3://$BUCKET_NAME
```

## Feilsøking

### Problem: Access Denied ved upload
- Sjekk at IAM brukeren har riktige S3 permissions
- Verifiser at bucket policy er korrekt konfigurert

### Problem: Nettside vises ikke
- Sjekk at website hosting er aktivert
- Verifiser at index.html finnes i bucket root
- Sjekk at public access ikke er blokkert

### Problem: CSS/JS lastes ikke
- Sjekk at filstier i HTML er relative
- Verifiser at alle filer er synkronisert til S3

## Ressurser
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CLI S3 Commands](https://docs.aws.amazon.com/cli/latest/reference/s3/)
- [S3 Static Website Hosting Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
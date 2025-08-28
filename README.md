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

#### Alternativ 1

```bash
aws configure
```

Du vil bli bedt om å oppgi:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (f.eks. `eu-north-1`)
- Default output format (trykk Enter for default)

**Sikkerhetstips:** Aldri commit AWS credentials til Git!

#### Alterativ 2

AWS credentials kan konfigureres på respository-nivå under Settings/Secrets/Codespaces.

<img width="1326" height="593" alt="image" src="https://github.com/user-attachments/assets/c2f62694-d70d-4844-9420-80a2939635a4" />


## Del 2: Opprett og konfigurer S3 Bucket

### Steg 1: Opprett en S3 bucket
Velg et unikt bucket-navn (må være globalt unikt):
Du kan *for eksempel* gjøre det slik, men velg gjerne et kreativt navn på din bucket. 

```bash
BUCKET_NAME="<finn på et unikt navn, små bokstever ikke underscore>"
aws s3 mb s3://$BUCKET_NAME --region eu-north-1
```

### Steg 2: Konfigurer bucket policy for offentlig tilgang

Opprett en fil `bucket-policy.json`, og Erstatt `BUCKET_NAME` med ditt bucket navn, 

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

Kjør følgende kommandoer i terminalen

* Fjerner  "block public access" (nødvendig for offentlig website)

```bash
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

```
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

### Se hvilke objekter som finnes i bucketen
```bash
aws s3 ls s3://$BUCKET_NAME/ --recursive
```

## Opprydding
Når du er ferdig med øvelsen, slett bucketen for å unngå kostnader:
```bash
# Tøm bucketen først
aws s3 rm s3://$BUCKET_NAME --recursive

# Slett bucketen
aws s3 rb s3://$BUCKET_NAME
```

# Viktige termer – AWS S3 Static Website Hosting (Laget av AI)

## Grunnleggende
- **AWS CLI**: Kommandolinje-verktøy for å kjøre AWS-kommandoer. Brukes her til å opprette bucket, sette policy og laste opp filer.  
- **GitHub Codespaces**: Sky-devmiljø i nettleseren. Du kjører alle AWS-kommandoer herfra.  

## Identitet & tilgang
- **IAM-bruker**: Brukerkonto i AWS med rettigheter. Trenger nøkler for programmatisk tilgang.  
- **Access keys (Access Key ID / Secret Access Key)**: Nøkkelpar for IAM-bruker som lar CLI autentisere seg. Må aldri committes til Git.  
- **`aws configure`**: Kommando som lagrer access keys, region og output-format lokalt i Codespaces.  

## S3-begreper
- **S3 bucket**: “Mappe” på toppnivå i S3 (globalt unikt navn). Lagrer nettsidefilene dine.  
- **Region**: Geografisk område (f.eks. `eu-north-1`). Påvirker endepunkt/URL og latency.  
- **Static website hosting**: Egenskap på en bucket som lar S3 serve filer over HTTP som en enkel nettside.  
- **Index document / Error document**: Standardfiler S3 server når en mappe/404 treffes (typisk `index.html` / `error.html`).  

## Offentlig tilgang
- **Block Public Access (BPA)**: Sikkerhetsinnstilling som blokkerer at en bucket/objekter kan bli offentlige. Må delvis skrus av for å hoste offentlig nettsted.  
- **Bucket policy**: JSON-policy som definerer *hvem* som kan gjøre *hva* på *hvilke* ressurser. Her brukes en policy som lar alle lese objekter (`s3:GetObject`).  

## CLI-kommandoer brukt
- **`aws s3 mb s3://BUCKET`**: Make bucket – oppretter en ny bucket.  
- **`aws s3api put-public-access-block`**: Endrer BPA-flaggene (tillat offentlig tilgang).  
- **`aws s3api put-bucket-policy --policy file://…`**: Legger på bucket-policy (offentlig lesetilgang).  
- **`aws s3 website s3://BUCKET --index-document … --error-document …`**: Slår på static website hosting og peker på standardfiler.  
- **`aws s3 sync website/ s3://BUCKET/ --delete`**: Laster opp filer og sletter det som ikke finnes lokalt (speiler).  
- **`aws s3 ls s3://BUCKET/ --recursive`**: Lister alle filer i bucketen.  
- **`aws s3 rm s3://BUCKET --recursive`**: Tømmer bucketen.  
- **`aws s3 rb s3://BUCKET`**: Sletter selve bucketen (må være tom først).  

## Ressurser
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CLI S3 Commands](https://docs.aws.amazon.com/cli/latest/reference/s3/)
- [S3 Static Website Hosting Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

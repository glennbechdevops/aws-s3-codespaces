# AWS S3 Static Website Hosting - Øvelse

## Mål

I denne øvelsen skal du lære å:
- Konfigurere AWS CLI i GitHub Codespaces
- Opprette en S3 bucket
- Konfigurere bucket for static website hosting
- Deploye statiske filer til S3

I denne oppgaven skal vi jobbe med **AWS CLI** (`aws` kommandolinje) og bli kjent med terminalen. Det er fint om du prøver å forstå hva hver enkelt kommando gjør, men det aller viktigste er:

* At du får tilgang til klassens AWS-miljø
* At du får tilgang til AWS fra terminalen i Codespaces

### CLI vs. web-konsoll

Alt vi gjør i denne labben kan også gjøres via AWS sitt web-brukergrensesnitt (konsollet). CLI er raskere, mer presis og lettere å automatisere — derfor bruker vi den her. Men det er lærerikt å se de samme ressursene med egne øyne.

**Utforskingsoppgave, parallelt med labben:** logg inn på web-konsollet her:

👉 https://244530008913.signin.aws.amazon.com/console

Bruk samme IAM-brukernavn og passord som du fikk utdelt (dette er en *bruker* med passord, ikke access keys). Etter hver del av labben, gå inn i konsollet og finn:

- **Etter Del 2:** Finn S3-bucketen din under tjenesten *S3*. Klikk deg inn på den, se på **Permissions**-fanen — der ligger både *Block public access* og *Bucket policy* du satte fra CLI.
- **Etter Del 3:** Under **Properties** → *Static website hosting* — der ser du at hostingen er skrudd på og hvilken URL bucketen har.
- **Under Del 3:** Klikk på **Objects**-fanen og se filene du sync'et opp.

Poenget er: CLI-kommandoene og musepekingen i konsollet gjør *samme sak* mot *samme API*. Når du ser koblingen mellom de to blir AWS mye mindre magisk.

## Forutsetninger
- GitHub konto med Codespaces tilgang
- AWS konto med IAM bruker og access keys, følg veiledning her ; https://github.com/glennbechdevops/aws-iam-accesskeys

## Hva er GitHub Codespaces?

GitHub Codespaces er et *ferdig oppsatt utviklingsmiljø som kjører i skyen*. Du trenger ikke å installere noe lokalt på PC-en — når du starter et codespace får du en Linux-maskin i nettleseren med VS Code, terminal, git og en rekke verktøy allerede installert. Alt du gjør skjer på denne skymaskinen, ikke på din egen PC.

I denne øvelsen bruker vi Codespaces fordi:
- Alle får *samme miljø*, uavhengig av om du har Mac, Windows eller Linux hjemme.
- AWS CLI er (som regel) allerede installert.
- Du kan lukke nettleseren og komme tilbake senere — maskinen er der fortsatt.

**Merk:** GitHub gir en gratis kvote med Codespaces-timer per måned. Husk å *stoppe* codespacet ditt når du er ferdig (fra github.com/codespaces), ellers går kvoten din raskt tom.

## Hva er en fork?

En **fork** er din egen kopi av et GitHub-repo, plassert under din egen brukerkonto. Når du forker `glennbechdevops/aws-s3-codespaces`, får du ditt eget repo `<ditt-brukernavn>/aws-s3-codespaces` som du kan endre på uten å påvirke originalen.

Hvorfor forke i stedet for bare å klone?
- Du kan gjøre egne endringer og commit'e dem til *ditt* repo.
- Codespaces startes fra et repo — hvis du vil ha ditt eget codespace med dine egne endringer, må du starte det fra din fork, ikke originalen.
- Det er slik man vanligvis jobber med åpen kildekode: fork → endre → send pull request tilbake.

Enkelt sagt: originalrepoet er "fasiten" fra læreren, forken er "din arbeidskopi".

## AWS-tjenester vi bruker i denne labben

- **IAM (Identity and Access Management)**: AWS sitt system for brukere, roller og rettigheter. Vi bruker en IAM-bruker med *access keys* slik at AWS CLI kan autentisere seg mot AWS på dine vegne.
- **S3 (Simple Storage Service)**: AWS sin objektlagring. Filer legges i "buckets" (som mapper på øverste nivå). En S3-bucket kan også konfigureres til å servere filene som en enkel nettside over HTTP — det er akkurat det vi gjør her.

## Del 1: Konfigurer AWS CLI i Codespaces

### Steg 1: Fork repoet og start Codespaces
1. Gå til dette repoet på GitHub og klikk **Fork** øverst til høyre. Velg din egen brukerkonto som eier.
2. Åpne *din fork* (URL-en skal nå starte med ditt brukernavn, ikke `glennbechdevops`).
3. Klikk den grønne **Code**-knappen → fanen **Codespaces** → **Create codespace on main**.
4. Vent et par minutter mens miljøet bygges. Når terminalen dukker opp nederst, er du klar.

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

#### Alternativ 2

AWS credentials kan konfigureres på repository-nivå under Settings/Secrets/Codespaces.

<img width="1326" height="593" alt="image" src="https://github.com/user-attachments/assets/c2f62694-d70d-4844-9420-80a2939635a4" />


## Del 2: Opprett og konfigurer S3 Bucket

### Steg 1: Opprett en S3 bucket
Velg et unikt bucket-navn (må være globalt unikt):
Du kan *for eksempel* gjøre det slik, men velg gjerne et kreativt navn på din bucket. 

```bash
BUCKET_NAME="<finn på et unikt navn, små bokstaver ikke underscore>"
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

### Steg 2: Få URL til nettstedet
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

## Bonusoppgave: Deploy din egen React-app

En React-app er, når den er bygget, bare statiske filer. Og statiske filer — det er S3 sitt hjemmebane. Lag noe. Deploy det. Del URL-en med en medstudent.

### Oppgaven

Finn på en React-app. Bygg den. Sync `dist/` til en ny S3-bucket på samme måte som du gjorde med `website/` tidligere i labben.

Hvordan du setter opp React-prosjektet er opp til deg. Google, ChatGPT, dokumentasjonen, en venn — velg selv.

### Ideer (jo rarere jo bedre)

- **"Er hotdog en sandwich?"** — én knapp, én meningsmåling, ett svar som er vitenskapelig kontroversielt.
- **Passiv-aggressiv to-do liste** som kommenterer valgene dine ("*Å, du la til «vaske klær» igjen. Fjerde gangen denne uken. Interessant.*").
- **Random norsk bygdenavn-generator** — kombiner to stavelser fra ekte stedsnavn til noe som høres helt reelt ut (Trøndelag+Hardanger = Trøndanger).
- **Kaffe-roulette:** trykk på knappen og få tildelt hvilken kollega/medstudent du må ta en kaffe med i dag.
- **"Hvor mange ganger kan jeg klikke denne knappen før nettleseren krasjer?"** — teller, konfetti, mørke krefter.
- **Undergangsklokken for helgen** — nedtelling til fredag kl 16:00, med stigende dramatikk jo nærmere du kommer.
- **Excuse-generator for hvorfor deploy feilet** — "DNS", "det er en race condition", "senior devopser er på hytta".
- **Tarot-kort for kodere** — trekk et kort, få en spådom ("Du vil skrive `console.log` og glemme å fjerne den før PR").
- **Simulator for å være en katt** — vandre rundt, dytte ting av bordet, sove i 14 timer.
- **En knapp som bare sier "NEI"** — men på 47 forskjellige måter.
- **Kart over verdens beste toaletter i Oslo**, med anmeldelser du selv finner på.
- Din egen versjon av noe helt annet. Overrask deg selv.

Bygg noe *du* synes er morsomt. Ingen skal karakter-vurdere ideen — vi vurderer at du fikk den ut på nettet.

### Ting å tenke på

- Prosjektet ditt trenger sin egen S3-bucket (samme oppskrift som over). Bruk et nytt, unikt navn.
- Etter `npm run build` er det innholdet i `dist/` (eller `build/`, avhengig av verktøy) du skal sync'e til S3 — ikke hele prosjektmappen.
- `--delete` på `aws s3 sync` er din venn når du deployer på nytt.
- Husk **Opprydding** når du er ferdig, også for denne bucketen.

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

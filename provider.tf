terraform {
  required_providers {
    dynatrace = {
      version = "1.58.6"
      source  = "dynatrace-oss/dynatrace"
    }
  }
}

/*
Die Verbindung zur DT-Umgebung ließe sich über folgenden Provider-Eintrag realisieren. 
provider "dynatrace" {
    dt_env_url    = "https://kwy24439.live.dynatrace.com"
    dt_api_token  = "#############" //kann bei Alex erfragt werden.
}

Aus Sicherheitsgründen (das Token hat admin-Rechte) setzen wir stattdessen manuell Umgebungsvariablen:

set DYNATRACE_ENV_URL=https://kwy24439.live.dynatrace.com
set DYNATRACE_API_TOKEN=############# //kann bei Alex erfragt werden.
*/
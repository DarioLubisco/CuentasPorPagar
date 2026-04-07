"""
Server MCP Reale per il Progetto Antigravity (Google Client).
Questo server funge da "Auditor Contabile" specializzato per il Venezuela (SENIAT).
"""

import os
import json
import re
from typing import Dict, Any, List, Optional
from mcp.server.fastmcp import FastMCP

# Inizializzazione del server FastMCP.
mcp = FastMCP("Antigravity-Auditor")

# COSTANTI VENEZUELA (Aggiornate Aprile 2026)
VALOR_UT = 43.00  # Bolívares (Gaceta Oficial Nº 43.140)
IVA_ESTANDAR = 0.16

# TABELLA RITENZIONI ISLR (Esempi comuni)
# Formato: { codice: { 'tasa': percentuale, 'sustraendo_ut': factor_ut } }
# Nota: Il sustraendo si applica solitamente a persone naturali residenti.
TABLA_ISLR = {
    "HON_PROF": {"tasa": 0.03, "sustraendo_ut": 0, "desc": "Honorarios Profesionales (Jurídicos)"},
    "HON_PROF_NAT": {"tasa": 0.05, "sustraendo_ut": 0, "desc": "Honorarios Profesionales (Naturales)"},
    "SERV_MANT": {"tasa": 0.02, "sustraendo_ut": 0, "desc": "Servicios y Mantenimiento (Jurídicos)"},
    "SERV_NAT": {"tasa": 0.01, "sustraendo_ut": 0, "desc": "Servicios (Naturales)"},
    "PUBLICIDAD": {"tasa": 0.03, "sustraendo_ut": 0, "desc": "Publicidad y Propaganda"},
    "FLETES": {"tasa": 0.03, "sustraendo_ut": 0, "desc": "Fletes y Transporte"}
}

def validar_rif(rif: str) -> bool:
    """Verifica il formato e il checksum di un RIF venezuelano."""
    rif = rif.upper().replace("-", "").replace(".", "")
    if not re.match(r"^[VJGPE]\d{9}$", rif):
        return False
    
    # Algoritmo Checksum RIF
    v_char = rif[0]
    num_part = rif[1:9]
    check_digit = int(rif[9])
    
    mapping = {"V": 4, "E": 8, "J": 12, "P": 16, "G": 20}
    weights = [3, 2, 7, 6, 5, 4, 3, 2]
    
    suma = mapping[v_char]
    for i, digit in enumerate(num_part):
        suma += int(digit) * weights[i]
    
    residuo = suma % 11
    digit_calc = 11 - residuo
    if digit_calc >= 10:
        digit_calc = 0
        
    return digit_calc == check_digit

@mcp.tool()
def auditar_retencion_iva(base_imponible: float, iva_porcentaje: float = 16.0, porcentaje_retencion: float = 75.0, monto_retener: float = 0.0) -> str:
    """
    Verifica se la ritenzione IVA calcolata è conforme alle regole SENIAT (75% o 100%).
    """
    iva_total = round(base_imponible * (iva_porcentaje / 100), 2)
    retencion_esperada = round(iva_total * (porcentaje_retencion / 100), 2)
    
    diff = abs(retencion_esperada - monto_retener)
    conforme = diff < 0.02
    
    report = [
        "--- AUDIT RITENZIONE IVA (SENIAT) ---",
        f"Base Imponibile: {base_imponible:,.2f} Bs.",
        f"IVA ({iva_porcentaje}%): {iva_total:,.2f} Bs.",
        f"% Ritenzione: {porcentaje_retencion}%",
        f"Ritenzione Attesa: {retencion_esperada:,.2f} Bs.",
        f"Ritenzione Applicata: {monto_retener:,.2f} Bs.",
        f"Stato: {'✅ CONFORME' if conforme else '❌ DISCREPANZA'}"
    ]
    
    if not conforme:
        report.append(f"ATTENZIONE: Differenza di {diff:,.2f} Bs. rilevata.")
        
    return "\n".join(report)

@mcp.tool()
def auditar_retencion_islr(base_imponible: float, codice_concetto: str, monto_retener: float, es_persona_natural: bool = False) -> str:
    """
    Verifica la ritenzione ISLR in base al codice concetto e all'Unità Tributaria (43 Bs).
    """
    if codice_concetto not in TABLA_ISLR:
        return f"Errore: Codice concetto '{codice_concetto}' non riconosciuto."
    
    info = TABLA_ISLR[codice_concetto]
    tasa = info["tasa"]
    
    # Calcolo del Sustraendo
    sustraendo = 0.0
    if es_persona_natural and info["sustraendo_ut"] > 0:
        sustraendo = info["sustraendo_ut"] * VALOR_UT
        
    retencion_esperada = round((base_imponible * tasa) - sustraendo, 2)
    if retencion_esperada < 0:
        retencion_esperada = 0.0
        
    diff = abs(retencion_esperada - monto_retener)
    conforme = diff < 0.02
    
    report = [
        "--- AUDIT RITENZIONE ISLR (VENEZUELA) ---",
        f"Concetto: {info['desc']}",
        f"Base: {base_imponible:,.2f} Bs.",
        f"Tasa Applicata: {tasa*100}%",
        f"Sustraendo: {sustraendo:,.2f} Bs. (UT: {VALOR_UT} Bs.)",
        f"Ritenzione Attesa: {retencion_esperada:,.2f} Bs.",
        f"Ritenzione Applicata: {monto_retener:,.2f} Bs.",
        f"Stato: {'✅ CONFORME' if conforme else '❌ DISCREPANZA'}"
    ]
    
    return "\n".join(report)

@mcp.tool()
def validar_datos_fiscales(rif: str, numero_factura: str, numero_control: str) -> str:
    """Valida i dati formali di una fattura venezuelana."""
    rif_ok = validar_rif(rif)
    
    # Il numero controllo solitamente è 00-12345678 o simile
    control_ok = bool(re.match(r"^\d{2}-\d{4,8}$", numero_control)) or bool(re.match(r"^\d{1,10}$", numero_control)) or bool(re.match(r"^[A-Z]\d{8}$", numero_control))
    
    report = [
        "--- VALIDAZIONE DATI FISCALI ---",
        f"RIF ({rif}): {'✅ VALIDO' if rif_ok else '❌ NON VALIDO'}",
        f"Numero Fattura: {numero_factura}",
        f"Numero Controllo: {numero_control} ({'✅ FORMATO OK' if control_ok else '⚠️ CONTROLLARE FORMATO'})"
    ]
    
    return "\n".join(report)

@mcp.tool()
def analizza_transazioni_sql(transazioni_json: str) -> str:
    """Analisi contabile base (quadratura)."""
    try:
        data = json.loads(transazioni_json)
        totale_dare = sum(float(t.get("dare", 0.0)) for t in data)
        totale_avere = sum(float(t.get("avere", 0.0)) for t in data)
        sbilancio = round(totale_dare - totale_avere, 2)
        quadratura = abs(sbilancio) < 0.01
        
        return f"--- RISULTATO ANALISI ---\nRecord: {len(data)}\nDare: {totale_dare:,.2f}\nAvere: {totale_avere:,.2f}\nStato: {'✅ IN PAREGGIO' if quadratura else '❌ SBILANCIATO ('+str(sbilancio)+' Bs.)'}"
    except Exception as e:
        return f"Errore: {str(e)}"

@mcp.tool()
def stato_sistema_auditor() -> str:
    """Restituisce lo stato corrente dell'Auditor."""
    return f"Antigravity Auditor (Venezuela) ONLINE. UT = {VALOR_UT} Bs. IVA = {IVA_ESTANDAR*100}%."

if __name__ == "__main__":
    print(f"[INFO] Auditor Antigravity avviato con UT = {VALOR_UT} Bs.")
    mcp.run()

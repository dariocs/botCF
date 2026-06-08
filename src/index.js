const readline = require("node:readline/promises");
const { stdin: input, stdout: output } = require("node:process");
const CodiceFiscale = require("codice-fiscale-js");

const MCP_URL = process.env.REMOTE_MCP_URL || "http://as400.it:3010/mcp";

function sanitizeText(value) {
  return String(value || "")
    .trim()
    .toUpperCase()
    .replace(/\s+/g, " ");
}

function sanitizeNaturalText(value) {
  return String(value || "")
    .trim()
    .replace(/\s+/g, " ");
}

function isFiscalCodeRequest(value) {
  const text = String(value || "").toLowerCase();
  return (
    (text.includes("calcol") || text.includes("calco")) &&
    (text.includes("codice fiscale") || text.includes("cf"))
  );
}

function extractInitialDataFromRequest(value) {
  const text = sanitizeNaturalText(value);
  const lowered = text.toLowerCase();
  const normalizedText = text
    .replace(/[,:;]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  const extracted = {
    cognome: "",
    nome: "",
    sesso: "",
    data_nascita: null,
    citta_nascita: "",
  };

  const cognomeMatch = text.match(/\bcognome\s*(?:e|:)?\s*([a-zA-ZÀ-ÖØ-öø-ÿ'\- ]{2,40})/i);
  if (cognomeMatch) {
    extracted.cognome = sanitizeText(cognomeMatch[1].split(/[,.;]/)[0]);
  }

  const nomeMatch = text.match(/\bnome\s*(?:e|:)?\s*([a-zA-ZÀ-ÖØ-öø-ÿ'\- ]{2,40})/i);
  if (nomeMatch) {
    extracted.nome = sanitizeText(nomeMatch[1].split(/[,.;]/)[0]);
  }

  const sonoMatch = normalizedText.match(
    /\bsono\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})/i
  );
  if (sonoMatch) {
    if (!extracted.nome) extracted.nome = sanitizeText(sonoMatch[1]);
    if (!extracted.cognome) extracted.cognome = sanitizeText(sonoMatch[2]);
  }

  const diMatch = normalizedText.match(
    /\b(?:codice\s+fiscale\s+di|di|per)\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})\b/i
  );
  if (diMatch) {
    if (!extracted.nome) extracted.nome = sanitizeText(diMatch[1]);
    if (!extracted.cognome) extracted.cognome = sanitizeText(diMatch[2]);
  }

  const directCfNameMatch = normalizedText.match(
    /\bcodice\s+fiscale\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})(?=\s+nat[oa]\b|\s+nata\b|\s+nato\b|\s+il\b|\s+del\b|$)/i
  );
  if (directCfNameMatch) {
    if (!extracted.nome) extracted.nome = sanitizeText(directCfNameMatch[1]);
    if (!extracted.cognome) extracted.cognome = sanitizeText(directCfNameMatch[2]);
  }

  const sessoMatch = text.match(/\bsesso\s*(?:e|:)?\s*([mMfF])\b/);
  if (sessoMatch) {
    extracted.sesso = sanitizeText(sessoMatch[1]);
  } else if (/\b(femmina|donna)\b/i.test(text)) {
    extracted.sesso = "F";
  } else if (/\b(maschio|uomo)\b/i.test(text)) {
    extracted.sesso = "M";
  } else if (/\bnata\b/i.test(text)) {
    extracted.sesso = "F";
  } else if (/\bnato\b/i.test(text)) {
    extracted.sesso = "M";
  }

  const cityExplicitMatch = text.match(
    /\b(?:citta|citt[àa]|comune)\s+di\s+nascita\s*(?:e|:)?\s*([a-zA-ZÀ-ÖØ-öø-ÿ'\-()., ]{2,60})/i
  );
  if (cityExplicitMatch) {
    extracted.citta_nascita = sanitizeNaturalText(cityExplicitMatch[1].split(/[.;]/)[0]);
  } else {
    const cityByBirthMatch = text.match(
      /\bnat[oa]\s+(?:a|ad|in)\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-()., ]+?)(?=\s+(?:il|nel|del|con|sesso|data|$)|[.;]|$)/i
    );
    if (cityByBirthMatch) {
      extracted.citta_nascita = sanitizeNaturalText(cityByBirthMatch[1]);
    }
  }

  if (!extracted.citta_nascita) {
    const cityAfterDateMatch = text.match(
      /\bnat[oa]\s+il\s+[^,.;]+\s+(?:a|ad|in)\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-()., ]+?)(?=\s+(?:con|sesso|nome|cognome|$)|[.;]|$)/i
    );
    if (cityAfterDateMatch) {
      extracted.citta_nascita = sanitizeNaturalText(cityAfterDateMatch[1]);
    }
  }

  const dateCandidates = [];
  const d8 = text.match(/\b\d{8}\b/g) || [];
  const iso = text.match(/\b\d{4}-\d{2}-\d{2}\b/g) || [];
  const slash = text.match(/\b\d{2}\/\d{2}\/\d{4}\b/g) || [];
  const slashShort = text.match(/\b\d{2}\/\d{2}\/\d{2}\b/g) || [];
  const natural = text.match(/\b\d{1,2}\s+[a-zA-ZÀ-ÖØ-öø-ÿ]+\s+(?:del\s+)?\d{2,4}\b/gi) || [];
  dateCandidates.push(...d8, ...iso, ...slash, ...slashShort, ...natural);

  for (const candidate of dateCandidates) {
    const parsed = parseBirthDateToInt(candidate);
    if (parsed) {
      extracted.data_nascita = parsed;
      break;
    }
  }

  if (!extracted.cognome && !extracted.nome && /\bmi chiamo\b/i.test(lowered)) {
    const chiamoMatch = normalizedText.match(
      /\bmi\s+chiamo\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30})(?:\s+([a-zA-ZÀ-ÖØ-öø-ÿ'\-]{2,30}))?/i
    );
    if (chiamoMatch) {
      extracted.nome = sanitizeText(chiamoMatch[1]);
      if (chiamoMatch[2]) {
        extracted.cognome = sanitizeText(chiamoMatch[2]);
      }
    }
  }

  return extracted;
}

function parseBirthDateToInt(value) {
  const clean = String(value || "").trim();

  if (/^\d{8}$/.test(clean)) {
    const year = Number(clean.slice(0, 4));
    const month = Number(clean.slice(4, 6));
    const day = Number(clean.slice(6, 8));
    if (isValidDate(year, month, day)) {
      return Number(clean);
    }
    return null;
  }

  if (/^\d{4}-\d{2}-\d{2}$/.test(clean)) {
    const [y, m, d] = clean.split("-").map(Number);
    if (isValidDate(y, m, d)) {
      return Number(`${y.toString().padStart(4, "0")}${m
        .toString()
        .padStart(2, "0")}${d.toString().padStart(2, "0")}`);
    }
  }

  if (/^\d{2}\/\d{2}\/\d{4}$/.test(clean)) {
    const [d, m, y] = clean.split("/").map(Number);
    if (isValidDate(y, m, d)) {
      return Number(`${y.toString().padStart(4, "0")}${m
        .toString()
        .padStart(2, "0")}${d.toString().padStart(2, "0")}`);
    }
  }

  if (/^\d{2}\/\d{2}\/\d{2}$/.test(clean)) {
    const [d, m, yy] = clean.split("/").map(Number);
    const y = normalizeTwoDigitYear(yy);
    if (isValidDate(y, m, d)) {
      return Number(`${y.toString().padStart(4, "0")}${m
        .toString()
        .padStart(2, "0")}${d.toString().padStart(2, "0")}`);
    }
  }

  const natural = parseItalianNaturalDate(clean);
  if (natural) {
    return natural;
  }

  return null;
}

function parseItalianNaturalDate(value) {
  const months = {
    gennaio: 1,
    gen: 1,
    febbraio: 2,
    feb: 2,
    marzo: 3,
    mar: 3,
    aprile: 4,
    apr: 4,
    maggio: 5,
    mag: 5,
    giugno: 6,
    giu: 6,
    luglio: 7,
    lug: 7,
    agosto: 8,
    ago: 8,
    settembre: 9,
    set: 9,
    ottobre: 10,
    ott: 10,
    novembre: 11,
    nov: 11,
    dicembre: 12,
    dic: 12,
  };

  const text = String(value || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ");

  const match = text.match(/^(\d{1,2})\s+([a-z]+)\s+(?:del\s+)?(\d{2}|\d{4})$/i);
  if (!match) {
    return null;
  }

  const day = Number(match[1]);
  const month = months[match[2]];
  if (!month) {
    return null;
  }

  const rawYear = Number(match[3]);
  const year = match[3].length === 4 ? rawYear : normalizeTwoDigitYear(rawYear);
  if (!isValidDate(year, month, day)) {
    return null;
  }

  return Number(`${year.toString().padStart(4, "0")}${month
    .toString()
    .padStart(2, "0")}${day.toString().padStart(2, "0")}`);
}

function normalizeTwoDigitYear(twoDigits) {
  const yy = Number(twoDigits);
  const currentYY = new Date().getUTCFullYear() % 100;
  return yy <= currentYY ? 2000 + yy : 1900 + yy;
}

function parseCityAndProvince(value) {
  const raw = String(value || "").trim();
  if (!raw) {
    return { city: "", province: undefined };
  }

  // Supporta input tipo: "Napoli NA", "Napoli, NA", "Napoli (NA)"
  const regex = /^(.*?)(?:\s*[,(]\s*|\s+)([A-Za-z]{2})\)?$/;
  const m = raw.match(regex);
  if (m && m[1].trim().length > 0) {
    const city = m[1].trim();
    const province = m[2].trim().toUpperCase();
    return { city, province };
  }

  return { city: raw, province: undefined };
}

function resolveComuneCode(value) {
  const { city, province } = parseCityAndProvince(value);
  if (!city) {
    return { ok: false, message: "La citta di nascita e obbligatoria." };
  }

  try {
    const code = CodiceFiscale.findLocationCode(city, province);
    return {
      ok: true,
      code,
      city: sanitizeText(city),
      province: province || "",
    };
  } catch (error) {
    const msg = String(error?.message || "");

    if (/more than one province/i.test(msg)) {
      return {
        ok: false,
        message:
          "Citta omonima trovata in piu province. Specifica anche la provincia (esempio: CASTRO (LE)).",
      };
    }

    return {
      ok: false,
      message:
        "Citta non trovata. Inserisci il nome comune italiano (esempio: Vigevano, Milano) e, se serve, la provincia.",
    };
  }
}

function isValidDate(year, month, day) {
  if (year < 1900 || year > 2100) return false;
  if (month < 1 || month > 12) return false;
  if (day < 1 || day > 31) return false;
  const dt = new Date(Date.UTC(year, month - 1, day));
  return (
    dt.getUTCFullYear() === year &&
    dt.getUTCMonth() === month - 1 &&
    dt.getUTCDate() === day
  );
}

async function callMcp(method, params) {
  const payload = {
    jsonrpc: "2.0",
    id: Date.now(),
    method,
    params,
  };

  const response = await fetch(MCP_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`MCP HTTP ${response.status}: ${body}`);
  }

  const raw = await response.text();
  const parsed = parseMcpResponse(raw);

  if (parsed.error) {
    const msg = parsed.error.message || "Errore MCP sconosciuto";
    throw new Error(msg);
  }

  return parsed.result;
}

function parseMcpResponse(raw) {
  const text = String(raw || "").trim();
  if (!text) return {};

  // Supporta sia JSON puro sia Server-Sent Events con righe data:
  if (text.startsWith("{")) {
    return JSON.parse(text);
  }

  const dataLine = text
    .split(/\r?\n/)
    .find((line) => line.trim().startsWith("data:"));

  if (!dataLine) {
    throw new Error("Risposta MCP non riconosciuta (manca riga data:).\n" + text);
  }

  const jsonPart = dataLine.slice(dataLine.indexOf(":") + 1).trim();
  return JSON.parse(jsonPart);
}

async function toolsList() {
  return callMcp("tools/list", {});
}

function extractToolText(result) {
  if (!result || !Array.isArray(result.content)) return "";
  const textParts = result.content
    .filter((item) => item && item.type === "text" && typeof item.text === "string")
    .map((item) => item.text.trim())
    .filter(Boolean);
  return textParts.join("\n").trim();
}

function extractFiscalCodeFromText(text) {
  const source = String(text || "").toUpperCase();
  const matches = source.match(/[A-Z]{6}[0-9LMNPQRSTUV]{2}[A-EHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]/g);
  return matches && matches.length > 0 ? matches[0] : "";
}

function formatBirthDateInt(value) {
  const s = String(value || "").trim();
  if (!/^\d{8}$/.test(s)) return s;
  return `${s.slice(6, 8)}/${s.slice(4, 6)}/${s.slice(0, 4)}`;
}

async function callCalcCodiceFiscale(args) {
  const result = await callMcp("tools/call", {
    name: "calc_codice_fiscale",
    arguments: args,
  });

  const text = extractToolText(result);
  if (text) {
    return {
      fiscalCode: extractFiscalCodeFromText(text),
      rawText: text,
    };
  }

  // fallback: tenta serializzazione in assenza di output testuale
  const rawText = JSON.stringify(result);
  return {
    fiscalCode: extractFiscalCodeFromText(rawText),
    rawText,
  };
}

async function askUntilValid(rl, prompt, validator, formatter = (v) => v) {
  while (true) {
    const answer = (await rl.question(prompt)).trim();
    const valid = await validator(answer);
    if (valid.ok) return formatter(answer, valid);
    output.write(`\n${valid.message}\n\n`);
  }
}

async function runChatbot() {
  const rl = readline.createInterface({ input, output });

  try {
    output.write("\nCiao, come posso esserti utile?\n");
    output.write("Tra le mie abilita c'e il calcolo del codice fiscale.\n");
    output.write("Puoi scrivermi direttamente la tua richiesta.\n\n");

    const requestText = await askUntilValid(
      rl,
      "Come posso aiutarti oggi? ",
      (v) => {
        const clean = sanitizeNaturalText(v);
        if (!clean) {
          return { ok: false, message: "Scrivi pure la tua richiesta in modo libero." };
        }
        if (!isFiscalCodeRequest(clean)) {
          return {
            ok: false,
            message:
              "Posso aiutarti con il calcolo del codice fiscale. Per favore chiedimi ad esempio: calcolami il codice fiscale.",
          };
        }
        return { ok: true };
      },
      (v) => sanitizeNaturalText(v)
    );

    const initialData = extractInitialDataFromRequest(requestText);

    output.write(
      "Perfetto. Raccolgo i dati necessari e ti chiedo solo quelli mancanti.\n"
    );
    output.write(
      "La data puo essere inserita come YYYYMMDD, YYYY-MM-DD, DD/MM/YYYY, 19 gennaio 1976 o 10 febbraio del 46.\n\n"
    );

    const listed = await toolsList();
    const hasTool = Array.isArray(listed?.tools)
      ? listed.tools.some((t) => t.name === "calc_codice_fiscale")
      : false;

    if (!hasTool) {
      throw new Error(
        "Il tool calc_codice_fiscale non risulta disponibile sul server MCP configurato."
      );
    }

    const cognome = initialData.cognome
      ? initialData.cognome
      : await askUntilValid(
          rl,
          "Mi dici il cognome? ",
          (v) => {
            const s = sanitizeText(v);
            if (!s) return { ok: false, message: "Mi serve il cognome per continuare." };
            if (s.length > 30) return { ok: false, message: "Massimo 30 caratteri." };
            return { ok: true };
          },
          sanitizeText
        );

    const nome = initialData.nome
      ? initialData.nome
      : await askUntilValid(
          rl,
          "Perfetto. Qual e il nome? ",
          (v) => {
            const s = sanitizeText(v);
            if (!s) return { ok: false, message: "Mi serve anche il nome." };
            if (s.length > 30) return { ok: false, message: "Massimo 30 caratteri." };
            return { ok: true };
          },
          sanitizeText
        );

    const sesso = initialData.sesso
      ? initialData.sesso
      : await askUntilValid(
          rl,
          "Mi indichi il sesso (M/F)? ",
          (v) => {
            const s = sanitizeText(v);
            if (s !== "M" && s !== "F") {
              return { ok: false, message: "Puoi rispondere solo con M oppure F." };
            }
            return { ok: true };
          },
          (v) => sanitizeText(v)
        );

    const data_nascita = initialData.data_nascita
      ? initialData.data_nascita
      : await askUntilValid(
          rl,
          "Qual e la data di nascita? ",
          (v) => {
            const parsed = parseBirthDateToInt(v);
            if (!parsed) {
              return {
                ok: false,
                message:
                  "Non ho capito la data. Prova con YYYYMMDD, YYYY-MM-DD, DD/MM/YYYY oppure con testo come 19 gennaio 1976 o 10 febbraio del 46.",
              };
            }
            return { ok: true };
          },
          (v) => parseBirthDateToInt(v)
        );

    let comuneResult = null;
    if (initialData.citta_nascita) {
      const preResolvedCity = resolveComuneCode(initialData.citta_nascita);
      if (preResolvedCity.ok) {
        comuneResult = preResolvedCity;
      }
    }

    if (!comuneResult) {
      comuneResult = await askUntilValid(
        rl,
        "In quale citta sei nato/a? (esempio: Vigevano, Milano) ",
        (v) => resolveComuneCode(v),
        (_v, valid) => valid
      );
    }

    output.write(
      `Perfetto, ho riconosciuto la citta: ${comuneResult.city}${
        comuneResult.province ? ` (${comuneResult.province})` : ""
      } -> ${comuneResult.code}\n`
    );

    output.write("\nSto calcolando il codice fiscale tramite MCP...\n");

    const calcResult = await callCalcCodiceFiscale({
      cognome,
      nome,
      sesso,
      data_nascita,
      comune_nasc: comuneResult.code,
    });

    output.write("\nRisultato:\n");
    if (calcResult.fiscalCode) {
      output.write(`Codice fiscale: ${calcResult.fiscalCode}\n`);
    } else {
      output.write("Codice fiscale: non rilevato automaticamente nella risposta MCP.\n");
    }

    output.write("Riepilogo dati usati:\n");
    output.write(`- Nome e cognome: ${nome} ${cognome}\n`);
    output.write(`- Sesso: ${sesso}\n`);
    output.write(`- Data di nascita: ${formatBirthDateInt(data_nascita)}\n`);
    output.write(
      `- Comune di nascita: ${comuneResult.city}${
        comuneResult.province ? ` (${comuneResult.province})` : ""
      } [${comuneResult.code}]\n\n`
    );
  } finally {
    rl.close();
  }
}

runChatbot().catch((err) => {
  output.write(`\nErrore: ${err.message}\n`);
  process.exitCode = 1;
});

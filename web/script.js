// Fonction pour charger les statistiques depuis Firebase Realtime Database
async function chargerStats() {
  // URL corrigée avec le nœud "users"
  const url = "https://simstation-33519-default-rtdb.europe-west1.firebasedatabase.app/users.json";

  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error("Erreur HTTP " + response.status);

    const data = await response.json();
    const tbody = document.querySelector("#dashboard tbody");
    tbody.innerHTML = "";

    let totalJoueurs = 0;

    // Chaque clé est un joueur (ex: "Josue")
    for (const nomJoueur in data) {
      const joueur = data[nomJoueur];
      const tr = document.createElement("tr");

      // Colonnes
      const tdNom = document.createElement("td");
      const tdHabitants = document.createElement("td");
      const tdBonheur = document.createElement("td");
      const tdEfficacite = document.createElement("td");
      const tdPollution = document.createElement("td");
      const tdSante = document.createElement("td");
      const tdTemps = document.createElement("td");

      // Remplissage
      tdNom.textContent = nomJoueur;
      tdHabitants.textContent = joueur.habitants || 0;
      tdBonheur.textContent = joueur.stats?.bonheur ?? "N/A";
      tdEfficacite.textContent = joueur.stats?.efficacite ?? "N/A";
      tdPollution.textContent = joueur.stats?.pollution ?? "N/A";
      tdSante.textContent = joueur.stats?.sante ?? "N/A";
      tdTemps.textContent = joueur.time ?? "N/A";

      // Ajout au tableau
      tr.appendChild(tdNom);
      tr.appendChild(tdHabitants);
      tr.appendChild(tdBonheur);
      tr.appendChild(tdEfficacite);
      tr.appendChild(tdPollution);
      tr.appendChild(tdSante);
      tr.appendChild(tdTemps);

      tbody.appendChild(tr);
      totalJoueurs++;
    }

    // Mise à jour du total
    document.getElementById("total").textContent = `Nombre total de joueurs : ${totalJoueurs}`;
  } catch (err) {
    document.getElementById("total").textContent = "Erreur : " + err;
  }
}

// Appel initial
chargerStats();

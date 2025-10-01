<?php
// Vérifie si une donnée a été envoyée
$habitants = isset($_POST['habitants']) ? intval($_POST['habitants']) : null;
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Nombre d'habitants</title>
</head>
<body>
    <h2>Nombre d'habitants du joueur</h2>

    <?php if ($habitants !== null): ?>
        <p>Le joueur a <strong><?php echo $habitants; ?></strong> habitants.</p>
    <?php else: ?>
        <p>Aucune donnée reçue.</p>
    <?php endif; ?>
</body>
</html>

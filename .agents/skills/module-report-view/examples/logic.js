/**
 * Standard Report View Logic Template
 * Follows the project standards for glassmorphism and SPA architecture.
 */

window.appState = window.appState || {};
window.appState.reportData = []; // Store fetched items
window.appState.sortConfig = { key: '', direction: 'asc' };

/**
 * Main Fetch Function
 * Manual trigger for Dates, Automatic for Dropdowns
 */
async function fetchReportData() {
  const params = new URLSearchParams({
    inicio: document.getElementById('fecha_inicio').value,
    fin: document.getElementById('fecha_fin').value,
    status: document.getElementById('filterStatus').value
  });

  try {
    const response = await fetch(`/api/reports/purchases?${params.toString()}`);
    const result = await response.json();

    if (result.data) {
      window.appState.reportData = result.data;
      renderTable();
    } else {
      showToast(result.message || 'Error al obtener datos', 'error');
    }
  } catch (error) {
    console.error('Fetch error:', error);
    showToast('Error de conexión con el servidor', 'error');
  }
}

/**
 * Filter Processing (Manual)
 */
function processFilters() {
  fetchReportData();
}

/**
 * Auto-Filter for Status Dropdown
 */
function autoFilter() {
  fetchReportData();
}

/**
 * Universal Search Box (Multiple Fields)
 */
function debouncedSearch() {
  clearTimeout(window.searchTimer);
  window.searchTimer = setTimeout(() => {
    const query = document.getElementById('universalSearch').value.toLowerCase();
    const filtered = window.appState.reportData.filter(item => {
      return (
        (item.num_control && item.num_control.toLowerCase().includes(query)) ||
        (item.num_factura && item.num_factura.toLowerCase().includes(query)) ||
        (item.proveedor_nombre && item.proveedor_nombre.toLowerCase().includes(query))
      );
    });
    renderTable(filtered);
  }, 300);
}

/**
 * Click-to-Sort Table Logic
 */
function sortTable(key) {
  const dir = (window.appState.sortConfig.key === key && window.appState.sortConfig.direction === 'asc') ? 'desc' : 'asc';
  window.appState.sortConfig = { key, direction: dir };

  const sortedData = [...window.appState.reportData].sort((a, b) => {
    if (a[key] < b[key]) return dir === 'asc' ? -1 : 1;
    if (a[key] > b[key]) return dir === 'asc' ? 1 : -1;
    return 0;
  });

  renderTable(sortedData);
  updateSortIcons(key, dir);
}

/**
 * UI Rendering
 */
function renderTable(data = window.appState.reportData) {
  const container = document.getElementById('reportContent');
  container.innerHTML = '';

  data.forEach(item => {
    const row = document.createElement('tr');
    row.className = 'glass-row';
    row.innerHTML = `
      <td>${item.num_control}</td>
      <td>${item.num_factura}</td>
      <td class="bold-text">${item.proveedor_nombre}</td>
      <td>${new Date(item.fecha).toLocaleDateString()}</td>
      <td><span class="badge ${item.estatus.toLowerCase()}">${item.estatus}</span></td>
      <td class="text-right">${formatCurrency(item.monto_total)}</td>
    `;
    container.appendChild(row);
  });

  // Re-initialize Lucide icons for template content
  lucide.createIcons();
}

/**
 * Helper: Export to Excel/PDF
 */
function exportReport() {
  showToast('Generando reporte...', 'info');
  // Placeholder for export functionality
}

/**
 * Standard Currency Formatter
 */
function formatCurrency(value) {
  return new Intl.NumberFormat('es-VE', {
    style: 'currency',
    currency: 'USD'
  }).format(value);
}

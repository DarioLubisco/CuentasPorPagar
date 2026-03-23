document.addEventListener('DOMContentLoaded', () => {
    // DOM Elements
    const tableBody = document.getElementById('tableBody');
    const searchInput = document.getElementById('searchInput');
    const filterDate = document.getElementById('filterDate');
    const filterDateHasta = document.getElementById('filterDateHasta');
    const filterStatus = document.getElementById('filterStatus');
    const refreshBtn = document.getElementById('refreshBtn');
    // Cashflow Filters
    const cashflowDateDesde = document.getElementById('cashflowDateDesde');
    const cashflowDateHasta = document.getElementById('cashflowDateHasta');
    const refreshCashflowBtn = document.getElementById('refreshCashflowBtn');

    // Summaries
    const totalDocsStr = document.getElementById('totalDocs');
    const totalSaldoBsStr = document.getElementById('totalSaldoBs');
    const totalSaldoUsdStr = document.getElementById('totalSaldoUsd');
    const selectedTotalBsStr = document.getElementById('selectedTotalBs');
    const selectedTotalUsdStr = document.getElementById('selectedTotalUsd');

    // Forecast Consolidated Params
    const paramFechaCero = document.getElementById('paramFechaCero');
    const paramCajaUsd = document.getElementById('paramCajaUsd');
    const paramCajaBs = document.getElementById('paramCajaBs');
    const paramRetardoDays = document.getElementById('paramRetardoDays');
    const fcToggleDelay = document.getElementById('fcToggleDelay');

    // Action Bar & Selection
    const selectAllCheckbox = document.getElementById('selectAllCheckbox');
    const planningActionBar = document.getElementById('planningActionBar');
    const planFecha = document.getElementById('planFecha');
    const planBanco = document.getElementById('planBanco');
    const submitPlanBtn = document.getElementById('submitPlanBtn');
    const cancelPlanBtn = document.getElementById('cancelPlanBtn');
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');

    // Forecast & Forecast Consolidated Elements
    const fsDateDesde = document.getElementById('fsDateDesde');
    const fsDateHasta = document.getElementById('fsDateHasta');
    const fcDateDesde = document.getElementById('fcDateDesde');
    const fcDateHasta = document.getElementById('fcDateHasta');
    const fcDateDesdePlan = document.getElementById('fcDateDesde'); // duplicated just in case

    const refreshForecastSalesBtn = document.getElementById('refreshForecastSalesBtn');
    const refreshForecastConsolidatedBtn = document.getElementById('refreshForecastConsolidatedBtn');

    window.currentData = [];

    // Provider Modals
    const providerCondModal = document.getElementById('providerCondModal');
    const editProviderCondModal = document.getElementById('editProviderCondModal');
    const providersTableBody = document.getElementById('providersTableBody');
    const editProvForm = document.getElementById('editProvForm');
    const providerSearchInput = document.getElementById('providerSearchInput');
    const providerActivoCheck = document.getElementById('providerActivoCheck');

    let fetchTimeout;

    // Currency Formatters
    const bsFormatter = new Intl.NumberFormat('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format;
    const usdFormatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: 2 }).format;

    const formatBs = (val) => `Bs.S ${bsFormatter(val)}`;

    // === Cashflow Params State Management ===
    const loadCashflowParams = () => {
        if (!paramFechaCero) return;
        const saved = JSON.parse(localStorage.getItem('cashflowParams') || '{}');

        setDateValue(paramFechaCero, saved.fechaCero || new Date().toISOString().split('T')[0]);
        paramCajaUsd.value = saved.cajaUsd !== undefined ? saved.cajaUsd : 0;
        paramCajaBs.value = saved.cajaBs !== undefined ? saved.cajaBs : 0;
        paramRetardoDays.value = saved.retardoDays !== undefined ? saved.retardoDays : 1;
        if (fcToggleDelay) {
            // Default to true if not explicitly saved as false
            fcToggleDelay.checked = saved.toggleDelay !== false;
        }
    };

    window.saveCashflowParams = () => {
        const params = {
            fechaCero: getDateValue(paramFechaCero),
            cajaUsd: parseFloat(paramCajaUsd.value) || 0,
            cajaBs: parseFloat(paramCajaBs.value) || 0,
            retardoDays: parseInt(paramRetardoDays.value) || 0,
            toggleDelay: fcToggleDelay ? fcToggleDelay.checked : false
        };
        localStorage.setItem('cashflowParams', JSON.stringify(params));

        // Force refresh next time dashboard is opened
        if (window.forecastConsChartInstance) {
            window.forecastConsChartInstance.destroy();
            window.forecastConsChartInstance = null;
        }

        // Refresh forecast immediately if we are viewing it
        if (document.querySelector('.view-section.active')?.id === 'view-forecast-consolidated') {
            fetchForecastConsolidated();
        }
    };

    // Auto-save listeners
    paramFechaCero?.addEventListener('change', saveCashflowParams);
    paramCajaUsd?.addEventListener('change', saveCashflowParams);
    paramCajaBs?.addEventListener('change', saveCashflowParams);
    paramRetardoDays?.addEventListener('change', saveCashflowParams);

    if (fcToggleDelay) {
        fcToggleDelay.addEventListener('change', () => {
            saveCashflowParams();
        });
    }

    // ==========================================

    // Date Formatter (DD/MM/YYYY)
    const formatDate = (dateString) => {
        if (!dateString) return '-';
        // Handle ISO dates yyyy-mm-dd
        if (dateString.includes('-')) {
            const parts = dateString.split('T')[0].split('-');
            if (parts.length === 3) return `${parts[2]}/${parts[1]}/${parts[0]}`;
        }
        const date = new Date(dateString);
        const d = String(date.getDate()).padStart(2, '0');
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const y = date.getFullYear();
        return `${d}/${m}/${y}`;
    };

    // --- Date Input Helper (Force DD/MM/YYYY display) ---
    // This trick switches between 'text' (formatted) and 'date' (native picker)
    const setupDateInput = (input) => {
        if (!input) return;

        const toDateFormat = () => {
            if (input.type === 'date') return;
            const raw = input.getAttribute('data-raw');
            input.type = 'date';
            if (raw) input.value = raw;
        };

        const toTextFormat = () => {
            let val = input.value;
            // If we are already in text mode, value might be formatted, check data-raw
            if (input.type === 'text') {
                val = input.getAttribute('data-raw') || val;
            }

            if (val && val.includes('-') && val.split('-').length === 3) {
                const raw = val.split('T')[0];
                input.setAttribute('data-raw', raw);
                const parts = raw.split('-');
                input.type = 'text';
                input.value = `${parts[2]}/${parts[1]}/${parts[0]}`;
            } else if (!val) {
                input.type = 'text';
                input.value = '';
                input.placeholder = 'DD/MM/AAAA';
            }
        };

        input.addEventListener('focus', toDateFormat);
        input.addEventListener('blur', toTextFormat);
        input.addEventListener('change', () => {
            if (input.type === 'date') input.setAttribute('data-raw', input.value);
            else if (input.type === 'text' && input.value.includes('-')) {
                // If somehow value changed to raw in text mode
                toTextFormat();
            }
        });

        // Initial state
        toTextFormat();
    };

    const getDateValue = (input) => {
        if (!input) return "";
        return input.getAttribute('data-raw') || input.value || "";
    };

    const setDateValue = (input, val) => {
        if (!input) return;
        input.setAttribute('data-raw', val);
        input.value = val;
        // Trigger formatting if setupDateInput was called
        const parts = val.split('-');
        if (parts.length === 3) {
            input.type = 'text';
            input.value = `${parts[2]}/${parts[1]}/${parts[0]}`;
        }
    };
    // -----------------------------------------------------
    // -----------------------------------------------------

    // Generic Table Sorting
    window.setupSortableTable = (tableId, arrayObjString, renderFuncName, sortClass = 'sortable', defaultSortKey = '') => {
        let sortCfg = { key: defaultSortKey, direction: 'asc' };
        document.querySelectorAll(`#${tableId} th.${sortClass}`).forEach(header => {
            header.addEventListener('click', () => {
                const key = header.getAttribute('data-sort');
                if (!key) return;

                if (sortCfg.key === key) {
                    sortCfg.direction = sortCfg.direction === 'asc' ? 'desc' : 'asc';
                } else {
                    sortCfg.key = key;
                    sortCfg.direction = 'asc';
                }

                document.querySelectorAll(`#${tableId} th.${sortClass} .sort-icon`).forEach(icon => {
                    icon.classList.remove('active', 'desc');
                });
                header.querySelector('.sort-icon').classList.add('active');
                if (sortCfg.direction === 'desc') header.querySelector('.sort-icon').classList.add('desc');

                let arr = window[arrayObjString];
                if (!arr) return;

                arr.sort((a, b) => {
                    let valA = a[sortCfg.key] !== undefined && a[sortCfg.key] !== null ? a[sortCfg.key] : '';
                    let valB = b[sortCfg.key] !== undefined && b[sortCfg.key] !== null ? b[sortCfg.key] : '';
                    if (typeof valA === 'string') valA = valA.toLowerCase();
                    if (typeof valB === 'string') valB = valB.toLowerCase();
                    if (valA < valB) return sortCfg.direction === 'asc' ? -1 : 1;
                    if (valA > valB) return sortCfg.direction === 'asc' ? 1 : -1;
                    return 0;
                });

                if (typeof window[renderFuncName] === 'function') {
                    window[renderFuncName]();
                }
            });
        });
    };

    // Determine status based on dates, balances and planned status
    const getBaseStatus = (item) => {
        // Use ONLY the invoice's SAACXP.Saldo to determine paid status.
        // SaldoAct is the provider's overall balance, so we ignore it here.
        const efectivSaldo = parseFloat(item.Saldo) || 0;
        if (efectivSaldo <= 0.01) return 'Pagado';

        const abonos = parseFloat(item.TotalBsAbonado) || 0;
        const monto  = parseFloat(item.Monto) || 0;
        if (monto > 0 && abonos >= (monto - 0.01)) return 'Pagado';

        const now   = new Date();
        const vDate = new Date(item.FechaV);
        if (vDate < now) return 'Vencido';

        return 'Pendiente';
    };

    const getStatusHtml = (item) => {
        const base = getBaseStatus(item);
        let html = '';
        if (base === 'Pagado') html = `<span class="status-badge status-paid">Pagado</span>`;
        if (base === 'Vencido') html = `<span class="status-badge status-overdue">Vencido</span>`;
        if (base === 'Pendiente') html = `<span class="status-badge status-pending">Pendiente</span>`;

        // Attributes (Flags)
        const flags = [];
        if (item.Plan_ID) flags.push(`<span title="Planificado: Banco ${item.Plan_Banco}">🗓️</span>`);
        if (item.Has_Abonos) flags.push(`<span title="Tiene Abonos Parciales">💵</span>`);
        if (item.Has_Retencion) flags.push(`<span title="Tiene Retenciones">🧾</span>`);

        if (flags.length > 0) {
            html += ` <div style="display: inline-flex; gap: 0.2rem; filter: grayscale(0.2); font-size: 1.1em;">${flags.join('')}</div>`;
        }

        return html;
    };

    const fetchData = async () => {
        tableBody.innerHTML = `<tr><td colspan="9" class="loading-cell"><div class="loader"></div><p>Cargando datos...</p></td></tr>`;

        try {
            const search = encodeURIComponent(searchInput.value);
            let url = `/api/cuentas-por-pagar?search=${search}`;
            const dDesde = getDateValue(filterDate);
            const dHasta = getDateValue(filterDateHasta);
            if (dDesde) url += `&desde=${dDesde}`;
            if (dHasta) url += `&hasta=${dHasta}`;
            const response = await fetch(url);

            if (!response.ok) throw new Error('Error al obtener datos del servidor');

            const json = await response.json();
            window.currentData = json.data || [];

            // Sort by FechaE ascending by default
            window.currentData.sort((a, b) => {
                const dateA = a.FechaE || '';
                const dateB = b.FechaE || '';
                if (dateA < dateB) return 1;
                if (dateA > dateB) return -1;
                return 0;
            });

            window.renderTable();
        } catch (error) {
            console.error('Fetch error:', error);
            tableBody.innerHTML = `<tr><td colspan="9" style="text-align: center; color: var(--danger); padding: 2rem;">Error al cargar datos.</td></tr>`;
        }
    };

    const recalculateSelection = () => {
        const selectedCheckboxes = document.querySelectorAll('.row-checkbox:checked');
        let selBs = 0;
        let selUsd = 0;

        selectedCheckboxes.forEach(cb => {
            const nroUnico = parseInt(cb.getAttribute('data-nrounico'));
            const item = window.currentData.find(d => d.NroUnico === nroUnico);
            if (item) {
                const saldo = parseFloat(item.Saldo) || 0;
                // Calculate USD and updated Bs
                const tasaEmi = parseFloat(item.TasaEmision) || 1;
                const tasaAct = parseFloat(item.TasaActual) || 1;
                const montoUsd = saldo / tasaEmi;
                const saldoActualizadoBs = montoUsd * tasaAct;

                selBs += saldoActualizadoBs;
                selUsd += montoUsd;
            }
        });

        selectedTotalBsStr.textContent = formatBs(selBs);
        selectedTotalUsdStr.textContent = usdFormatter(selUsd);

        // Show/hide action bar
        const editInvoiceBtn = document.getElementById('editInvoiceBtn');
        if (selectedCheckboxes.length > 0) {
            planningActionBar.style.display = 'flex';
        } else {
            planningActionBar.style.display = 'none';
        }
        // Show edit button only when exactly 1 row selected
        if (editInvoiceBtn) {
            editInvoiceBtn.style.display = selectedCheckboxes.length === 1 ? 'inline-flex' : 'none';
        }

        const btnGenerarRetencion = document.getElementById('btnGenerarRetencion');
        if (btnGenerarRetencion) {
            btnGenerarRetencion.style.display = selectedCheckboxes.length >= 1 ? 'inline-flex' : 'none';
        }

        const btnPagoMultiple = document.getElementById('btnPagoMultiple');
        if (btnPagoMultiple) {
            btnPagoMultiple.style.display = selectedCheckboxes.length >= 2 ? 'inline-flex' : 'none';
        }

        // Update 'Select All' state
        selectAllCheckbox.checked = selectedCheckboxes.length === document.querySelectorAll('.row-checkbox').length && window.currentData.length > 0;
    };

    window.renderTable = () => {
        const baseStatusValue = document.getElementById('filterStatusBase')?.value || 'TODOS_ACTIVOS';
        const requiresPlan = document.getElementById('filterAttrPlanificado')?.checked;
        const requiresAbonos = document.getElementById('filterAttrAbonos')?.checked;
        const requiresReten = document.getElementById('filterAttrRetenciones')?.checked;
        const requiresCDebito = document.getElementById('filterAttrCDebito')?.checked;

        const filteredData = window.currentData.filter(item => {
            const baseStatus = getBaseStatus(item); // 'Pagado', 'Pendiente', 'Vencido'

            // Base Status Match
            let baseMatch = false;
            if (baseStatusValue === 'TODOS') {
                baseMatch = true;
            } else if (baseStatusValue === 'TODOS_ACTIVOS') {
                baseMatch = (baseStatus === 'Pendiente' || baseStatus === 'Vencido');
            } else if (baseStatusValue === 'PENDIENTE') {
                baseMatch = (baseStatus === 'Pendiente');
            } else if (baseStatusValue === 'VENCIDO') {
                baseMatch = (baseStatus === 'Vencido');
            } else if (baseStatusValue === 'PAGADO') {
                baseMatch = (baseStatus === 'Pagado');
            } else if (baseStatusValue === 'CONTADO_ERROR') {
                // CONTADO error: Pagado + same FechaI/FechaE + no abonos in Procurement
                const fechaI = (item.FechaI || '').split('T')[0];
                const fechaE = (item.FechaE || '').split('T')[0];
                const sameDates = fechaI && fechaE && fechaI === fechaE;
                baseMatch = (baseStatus === 'Pagado') && sameDates && !item.Has_Abonos;
            }

            if ((requiresCDebito || requiresAbonos) && baseStatus === 'Pagado' && baseStatusValue === 'TODOS_ACTIVOS') {
                baseMatch = true;
            }

            if (!baseMatch) return false;

            // Extra Conditions (AND Logic)
            if (requiresPlan && !item.Plan_ID) return false;
            if (requiresAbonos && !item.Has_Abonos) return false;
            if (requiresReten && !item.Has_Retencion) return false;
            if (requiresCDebito) {
                const totAbonado = parseFloat(item.TotalBsAbonado) || 0;
                const totOrig = parseFloat(item.Monto) || 0;
                if (totAbonado <= totOrig + 0.1) return false;
            }

            return true;
        });

        if (filteredData.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="9" style="text-align: center; color: var(--text-secondary); padding: 2rem;">No se encontraron registros.</td></tr>`;
            totalDocsStr.textContent = '0';
            totalSaldoBsStr.textContent = 'Bs 0.00';
            totalSaldoUsdStr.textContent = '$0.00';
            return;
        }

        let totalBs = 0;
        let totalUsd = 0;

        const rowsHtml = filteredData.map((item, index) => {
            const saldo = parseFloat(item.Saldo) || 0;
            const tasaEmi = parseFloat(item.TasaEmision) || 1;
            const tasaAct = parseFloat(item.TasaActual) || 1;

            const montoUsd = saldo / tasaEmi;
            const saldoActualizadoBs = montoUsd * tasaAct;

            totalBs += saldoActualizadoBs;
            totalUsd += montoUsd;

            // Allow selection: always for active invoices, also for paid if CONTADO_ERROR or PAGADO filter
            const currentFilter = document.getElementById('filterStatusBase')?.value || 'TODOS_ACTIVOS';
            const canSelect = (saldo > 0.01) || currentFilter === 'CONTADO_ERROR' || currentFilter === 'PAGADO' || currentFilter === 'TODOS';
            const checkboxHtml = canSelect
                ? `<input type="checkbox" class="row-checkbox" data-index="${index}" data-nrounico="${item.NroUnico}">`
                : `<input type="checkbox" disabled>`;

            // Highlight planned rows
            const rowClass = item.Plan_ID ? 'planned-row' : '';

            return `
                <tr class="${rowClass}">
                    <td class="col-checkbox">${checkboxHtml}</td>
                    <td>${formatDate(item.FechaE)}</td>
                    <td>${formatDate(item.FechaV)}</td>
                    <td style="font-weight: 500;">${item.NumeroD || '-'}</td>
                    <td>${item.NumeroD_SAPAGCXP || '-'}</td>
                    <td>${item.Descrip || '-'}</td>
                    <td class="amount">${formatBs(saldoActualizadoBs)}</td>
                    <td class="amount us-amount">${usdFormatter(montoUsd)}</td>
                    <td>${getStatusHtml(item)}</td>
                    <td>
                        <div style="display:flex; gap:0.4rem;">
                            <button class="btn-icon" title="Gestionar Abonos" onclick="openAbonosPanel('${item.CodProv}', '${item.NumeroD}')">
                                <i data-lucide="calculator" size="16"></i>
                            </button>
                            <button class="btn-icon" title="Generar Retenci&#243;n" onclick="openRetencionFromMain('${item.CodProv}', '${item.NumeroD}')" style="color:#eab308;">
                                <i data-lucide="receipt" size="16"></i>
                            </button>
                            <button class="btn-icon" title="Nota de Cr&#233;dito" onclick="openNCFromMain('${item.CodProv}', '${item.NumeroD}')" style="color:#10b981;">
                                <i data-lucide="file-plus" size="16"></i>
                            </button>
                            <button class="btn-icon" title="Nota de D&#233;bito" onclick="openNDFromMain('${item.CodProv}', '${item.NumeroD}')" style="color:#ef4444;">
                                <i data-lucide="file-minus" size="16"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');

        tableBody.innerHTML = rowsHtml;
        totalDocsStr.textContent = filteredData.length.toLocaleString();
        totalSaldoBsStr.textContent = formatBs(totalBs);
        totalSaldoUsdStr.textContent = usdFormatter(totalUsd);

        lucide.createIcons();

        // Attach listeners to checkboxes
        document.querySelectorAll('.row-checkbox').forEach(cb => {
            cb.addEventListener('change', recalculateSelection);
        });

        // Reset selection state
        recalculateSelection();
    };

    // Toggle Sidebar
    sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('collapsed');
        // Let the CSS transition handle layout shifts, resize chart if it exists
        setTimeout(() => { if (window.cashflowChartInstance) window.cashflowChartInstance.resize(); }, 300);
    });

    // Events
    refreshCashflowBtn.addEventListener('click', () => {
        fetchCashflow();
    });

    document.getElementById('filterStatusBase')?.addEventListener('change', window.renderTable);
    document.getElementById('filterAttrPlanificado')?.addEventListener('change', window.renderTable);
    document.getElementById('filterAttrAbonos')?.addEventListener('change', window.renderTable);
    document.getElementById('filterAttrRetenciones')?.addEventListener('change', window.renderTable);
    document.getElementById('filterAttrCDebito')?.addEventListener('change', window.renderTable);

    searchInput.addEventListener('input', () => {
        clearTimeout(fetchTimeout);
        fetchTimeout = setTimeout(fetchData, 500);
    });

    refreshBtn.addEventListener('click', () => {
        const base = document.getElementById('filterStatusBase');
        if (base) base.value = 'TODOS_ACTIVOS';
        ['filterAttrPlanificado', 'filterAttrAbonos', 'filterAttrRetenciones', 'filterAttrCDebito'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.checked = false;
        });
        fetchData();
    });
    filterDate.addEventListener('change', fetchData);
    filterDateHasta.addEventListener('change', fetchData);

    selectAllCheckbox.addEventListener('change', (e) => {
        const isChecked = e.target.checked;
        document.querySelectorAll('.row-checkbox').forEach(cb => {
            cb.checked = isChecked;
        });
        recalculateSelection();
    });

    cancelPlanBtn.addEventListener('click', () => {
        document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
        recalculateSelection();
    });

    submitPlanBtn.addEventListener('click', async () => {
        const selectedNros = Array.from(document.querySelectorAll('.row-checkbox:checked'))
            .map(cb => parseInt(cb.getAttribute('data-nrounico')));

        const fecha = getDateValue(planFecha);
        const banco = planBanco.value;

        if (selectedNros.length === 0) return alert('Seleccione al menos una factura.');
        if (!fecha) return alert('Debe seleccionar una Fecha Planificada.');
        if (!banco) return alert('Debe seleccionar un Banco.');

        try {
            submitPlanBtn.disabled = true;
            submitPlanBtn.innerHTML = '<i data-lucide="loader" class="spin"></i> Guardando...';

            const response = await fetch('/api/plan-pagos', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    nros_unicos: selectedNros,
                    fecha_planificada: fecha,
                    banco: banco
                })
            });

            if (!response.ok) throw new Error('Error al guardar plan de pago');

            // Clean up UI and reload
            setDateValue(planFecha, '');
            planBanco.value = '';
            await fetchData();

        } catch (error) {
            console.error(error);
            alert('Error al intentar planificar pagos.');
        } finally {
            submitPlanBtn.disabled = false;
            submitPlanBtn.innerHTML = '<i data-lucide="calendar-check"></i> Planificar Pago';
            lucide.createIcons();
        }
    });

    const unplanBtn = document.getElementById('unplanBtn');
    unplanBtn?.addEventListener('click', async () => {
        const selectedNros = Array.from(document.querySelectorAll('.row-checkbox:checked'))
            .map(cb => parseInt(cb.getAttribute('data-nrounico')));

        if (selectedNros.length === 0) return alert('Seleccione al menos una factura.');
        if (!confirm(`¿Seguro que desea reversar la planificación de ${selectedNros.length} factura(s)?`)) return;

        try {
            unplanBtn.disabled = true;
            unplanBtn.innerHTML = '<i data-lucide="loader" class="spin"></i> Procesando...';

            const response = await fetch('/api/plan-pagos', {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ nros_unicos: selectedNros })
            });

            if (!response.ok) throw new Error('Error al reversar plan de pago');

            document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
            recalculateSelection();
            await fetchData();

        } catch (error) {
            console.error(error);
            alert('Error al intentar reversar la planificación.');
        } finally {
            unplanBtn.disabled = false;
            unplanBtn.innerHTML = '<i data-lucide="calendar-x"></i> Reversar';
            lucide.createIcons();
        }
    });

    // --- Export Functionality ---
    const handleExport = (reportType, dateDesde = null, dateHasta = null) => {
        let url = `/api/export/${reportType}`;
        const params = new URLSearchParams();
        if (dateDesde) params.append('desde', dateDesde);
        if (dateHasta) params.append('hasta', dateHasta);
        if (params.toString()) url += '?' + params.toString();
        window.location.href = url;
    };

    document.getElementById('exportCxpBtn')?.addEventListener('click', () => {
        const d1 = getDateValue(document.getElementById('filterDate'));
        const d2 = getDateValue(document.getElementById('filterDateHasta'));
        handleExport('cuentas-por-pagar', d1, d2);
    });

    document.getElementById('exportComprasBtn')?.addEventListener('click', () => {
        const d1 = getDateValue(document.getElementById('comprasDesde'));
        const d2 = getDateValue(document.getElementById('comprasHasta'));
        handleExport('compras', d1, d2);
    });

    document.getElementById('exportAgingBtn')?.addEventListener('click', () => {
        handleExport('aging');
    });

    document.getElementById('exportDebitNotesBtn')?.addEventListener('click', () => {
        handleExport('debit-notes');
    });

    // --- SPA Routing ---
    const navItems = document.querySelectorAll('.nav-item, .nav-item-sub');
    const views = document.querySelectorAll('.view-section');

    const switchView = (viewId) => {
        // Update Nav
        navItems.forEach(item => {
            if (item.getAttribute('data-view') === viewId) item.classList.add('active');
            else item.classList.remove('active');
        });

        // Hide all views, show selected
        views.forEach(view => {
            if (view.id === `view-${viewId}`) view.classList.add('active');
            else view.classList.remove('active');
        });

        // Trigger fetches if needed
        if (viewId === 'dashboard') fetchData();
        else if (viewId === 'compras') fetchCompras();
        else if (viewId === 'aging') fetchAging();
        else if (viewId === 'cashflow') fetchCashflow();
        else if (viewId === 'forecast-sales') fetchForecastSales();
        else if (viewId === 'forecast-consolidated') fetchForecastConsolidated();
        else if (viewId === 'forecast-events') fetchForecastEvents();
        else if (viewId === 'debit-notes') fetchDebitNotes();
        else if (viewId === 'credit-notes') fetchCreditNotes();
        else if (viewId === 'dpo') fetchDpo();
        else if (viewId === 'expense-templates') fetchExpenseTemplates();
        else if (viewId === 'expense-batch') fetchSavedBatch();
        else if (viewId === 'sedematri') { /* Static view, no fetch needed for now */ }
        else if (viewId === 'retenciones') {
            // fetchRetenciones is defined inside the retencionesView block below
            const tbody = document.getElementById('retencionesTableBody');
            if (tbody && typeof window._fetchRetenciones === 'function') window._fetchRetenciones();
        }
    };

    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const viewId = item.getAttribute('data-view') || item.closest('.nav-item, .nav-item-sub').getAttribute('data-view');
            if (viewId) switchView(viewId);
        });
    });

    // --- Reports Fetches ---
    document.getElementById('refreshDebitNotesBtn')?.addEventListener('click', () => fetchDebitNotes());

    const fetchDebitNotes = async () => {
        const tbody = document.getElementById('debitNotesTableBody');
        if (!tbody) return;

        tbody.innerHTML = `<tr><td colspan="10" class="loading-cell"><div class="loader"></div><p>Cargando notas de débito...</p></td></tr>`;

        try {
            const search = document.getElementById('dnFilterProv')?.value || "";
            const estatus = document.getElementById('dnFilterEstatus')?.value || "";
            let url = `/api/procurement/debit-notes?estatus=${estatus}`;
            if (search) url += `&search=${encodeURIComponent(search)}`;

            const res = await fetch(url);
            if (!res.ok) throw new Error("Error loading debit notes");
            const data = await res.json();

            if (!data.data || data.data.length === 0) {
                tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-secondary);">No hay notas de débito pendientes.</td></tr>`;
                updateDnActionBar();
                return;
            }

            tbody.innerHTML = data.data.map(d => {
                const isEmitida = d.Estatus === 'EMITIDA';
                return `
                <tr data-cod="${d.CodProv}" data-num="${d.NumeroD}" data-reten="${d.MontoRetencionBs}">
                    <td><input type="checkbox" class="dn-item-check" ${isEmitida ? 'disabled title="Ya emitida"' : ''}></td>
                    <td>${d.ProveedorNombre || '-'}</td>
                    <td><span style="font-weight: 500;">${d.NumeroD}</span></td>
                    <td>${formatDate(d.FechaEmision)}</td>
                    <td class="amount">${formatBs(d.MontoOriginalBs)}</td>
                    <td class="amount">${formatBs(d.TotalBsAbonado)}</td>
                    <td class="amount" style="color: var(--danger); font-weight: bold;">${formatBs(d.MontoNotaDebitoBs)}</td>
                    <td class="amount" style="color: var(--warning);">${formatBs(d.MontoRetencionBs)}</td>
                    <td style="text-align: center;">
                        <span class="badge ${d.Estatus === 'PENDIENTE' ? 'badge-danger' : (d.Estatus === 'EMITIDA' ? 'badge-success' : 'badge-warning')}">${d.Estatus}</span>
                    </td>
                    <td>${d.NotaDebitoID || '-'}</td>
                </tr>
            `}).join('');

            // Attach event listeners to checkboxes
            const selectAllCheck = document.getElementById('dnSelectAll');
            const itemChecks = document.querySelectorAll('.dn-item-check:not([disabled])');
            if (selectAllCheck) {
                selectAllCheck.checked = false;
                selectAllCheck.addEventListener('change', (e) => {
                    itemChecks.forEach(chk => chk.checked = e.target.checked);
                    updateDnActionBar();
                });
            }

            itemChecks.forEach(chk => {
                chk.addEventListener('change', () => {
                    if (selectAllCheck) {
                        selectAllCheck.checked = Array.from(itemChecks).every(c => c.checked);
                    }
                    updateDnActionBar();
                });
            });
            updateDnActionBar();

        } catch (error) {
            console.error(error);
            tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--danger);">Error al cargar notas de débito.</td></tr>`;
        }
    };

    const getSelectedDebitNotes = () => {
        const rows = document.querySelectorAll('#debitNotesTableBody tr');
        const selected = [];
        rows.forEach(r => {
            const chk = r.querySelector('.dn-item-check');
            if (chk && chk.checked) {
                selected.push({
                    CodProv: r.getAttribute('data-cod'),
                    NumeroD: r.getAttribute('data-num'),
                    _estimatedReten: parseFloat(r.getAttribute('data-reten') || 0)
                });
            }
        });
        return selected;
    };

    const updateDnActionBar = () => {
        const selected = getSelectedDebitNotes();
        const bar = document.getElementById('debitNotesActionBar');
        const countSpan = document.getElementById('dnSelectedCount');
        if (selected.length > 0) {
            countSpan.textContent = selected.length;
            bar.style.display = 'flex';
        } else {
            bar.style.display = 'none';
        }
    };

    document.getElementById('btnSendDebitNotes')?.addEventListener('click', async () => {
        const selected = getSelectedDebitNotes();
        if (selected.length === 0) return;
        if (!confirm(`¿Enviar solicitud y generar correos para ${selected.length} facturas?`)) return;

        const btn = document.getElementById('btnSendDebitNotes');
        const origText = btn.innerHTML;
        btn.innerHTML = `<i data-lucide="loader" class="rotating"></i> Enviando...`;
        btn.disabled = true;

        try {
            const res = await fetch('/api/procurement/debit-notes/send-request', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ Invoices: selected })
            });
            if (!res.ok) throw new Error("Error enviando solicitud");
            alert("Solicitudes de correo procesadas/marcadas con éxito.");
            fetchDebitNotes();
        } catch (err) {
            console.error(err);
            alert("Error al enviar solicitudes. Revise si el correo está configurado en el backend.");
        } finally {
            btn.innerHTML = origText;
            btn.disabled = false;
            lucide.createIcons();
        }
    });

    document.getElementById('refreshDebitNotesBtn')?.addEventListener('click', () => fetchDebitNotes());
    document.getElementById('dnFilterProv')?.addEventListener('input', () => {
        clearTimeout(fetchTimeout);
        fetchTimeout = setTimeout(fetchDebitNotes, 500);
    });
    document.getElementById('dnFilterEstatus')?.addEventListener('change', fetchDebitNotes);

    const registerDebitNoteModal = document.getElementById('registerDebitNoteModal');

    document.getElementById('btnRegisterDebitNote')?.addEventListener('click', () => {
        const selected = getSelectedDebitNotes();
        if (selected.length === 0) return;

        document.getElementById('dnInputNumero').value = '';

        const listContainer = document.getElementById('dnSelectedInvoicesList');
        if (listContainer) {
            listContainer.innerHTML = selected.map((s, idx) => `
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">
                    <div>
                        <span style="font-size: 0.85rem; color: var(--text-secondary);">Factura:</span>
                        <strong style="display: block;">${s.NumeroD}</strong>
                    </div>
                    <div>
                        <span style="font-size: 0.85rem; color: var(--text-secondary);">V. Editable (Bs):</span>
                        <input type="number" id="retenInput_${idx}" class="form-control" step="0.01" value="${s._estimatedReten.toFixed(2)}" required>
                    </div>
                </div>
            `).join('');
        }

        registerDebitNoteModal.classList.add('active');
    });

    window.closeRegisterDebitNoteModal = () => {
        registerDebitNoteModal.classList.remove('active');
    };

    document.getElementById('registerDebitNoteForm')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const num = document.getElementById('dnInputNumero').value.trim();
        if (!num) return;

        const selected = getSelectedDebitNotes();
        if (selected.length === 0) return;

        // Asignar el monto exacto tipeado por el usuario en cada factura
        selected.forEach((s, idx) => {
            const inputVal = parseFloat(document.getElementById(`retenInput_${idx}`).value || 0);
            s.MontoRetencionBs = inputVal;
            // Quitamos la estimacion inicial
            delete s._estimatedReten;
        });

        const btn = e.target.querySelector('button[type="submit"]');
        const origText = btn.innerHTML;
        btn.innerHTML = `<i data-lucide="loader" class="rotating"></i> Cargando...`;
        btn.disabled = true;

        try {
            const res = await fetch('/api/procurement/debit-notes/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ Invoices: selected, NotaDebitoID: num })
            });
            if (!res.ok) throw new Error("Error al registrar");
            closeRegisterDebitNoteModal();
            fetchDebitNotes();
        } catch (err) {
            console.error(err);
            alert("Ocurrió un error registrando la Nota de Débito.");
        } finally {
            btn.innerHTML = origText;
            btn.disabled = false;
            lucide.createIcons();
        }
    });

    // --- Credit Notes Logic ---
    const fetchCreditNotes = async () => {
        const tbody = document.getElementById('creditNotesTableBody');
        if (!tbody) return;

        tbody.innerHTML = `<tr><td colspan="10" class="loading-cell"><div class="loader"></div><p>Cargando notas de crédito...</p></td></tr>`;

        try {
            const provFilter = document.getElementById('cnFilterProv')?.value || "";
            const statusFilter = document.getElementById('cnFilterEstatus')?.value || "";
            let url = `/api/procurement/credit-notes?estatus=${statusFilter}`;
            if (provFilter) url += `&search=${encodeURIComponent(provFilter)}`;

            const res = await fetch(url);
            if (!res.ok) throw new Error("Error loading credit notes");
            const data = await res.json();

            if (!data.data || data.data.length === 0) {
                tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-secondary);">No hay notas de crédito registradas.</td></tr>`;
                return;
            }

            tbody.innerHTML = data.data.map(d => {
                const isPendiente = d.Estatus === 'PENDIENTE';
                return `
                <tr>
                    <td>${d.CodProv}</td>
                    <td title="${d.Observacion || ''}">${d.NumeroD || '-'}</td>
                    <td><span class="badge badge-info" style="background: rgba(99,102,241,0.15); color: var(--primary-accent); padding: 2px 6px; border-radius: 4px; font-size: 0.8rem;">${d.Motivo}</span></td>
                    <td class="amount">${formatBs(d.MontoBs)}</td>
                    <td class="amount">${(parseFloat(d.TasaCambio) || 0).toFixed(4)}</td>
                    <td class="amount us-amount" style="font-weight: 600;">${usdFormatter(d.MontoUsd || 0)}</td>
                    <td>${formatDate(d.FechaSolicitud)}</td>
                    <td style="text-align: center;">
                        <span class="status-badge ${d.Estatus === 'PENDIENTE' ? 'status-pending' : (d.Estatus === 'APLICADA' ? 'status-paid' : 'status-overdue')}">
                            ${d.Estatus}
                        </span>
                    </td>
                    <td>${d.NotaCreditoID || '-'}</td>
                    <td style="text-align: center;">
                        <div style="display: flex; gap: 0.5rem; justify-content: center;">
                            ${isPendiente ? `
                                <button class="btn btn-sm btn-primary" onclick="applyCreditNote(${d.Id})" title="Aplicar como Abono" style="padding: 0.2rem 0.5rem;">
                                    <i data-lucide="check" style="width:14px;height:14px;"></i>
                                </button>
                                <button class="btn btn-sm btn-secondary" onclick="anularCreditNote(${d.Id})" title="Anular" style="padding: 0.2rem 0.5rem; color: var(--danger);">
                                    <i data-lucide="slash" style="width:14px;height:14px;"></i>
                                </button>
                            ` : ''}
                            <button class="btn btn-sm btn-secondary" onclick="deleteCreditNote(${d.Id || d.ID || d.id})" title="Eliminar Permanentemente" style="padding: 0.2rem 0.5rem; color: var(--danger); border-color: rgba(239, 68, 68, 0.2);">
                                <i data-lucide="trash-2" style="width:14px;height:14px;"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `}).join('');
            lucide.createIcons();
        } catch (e) {
            console.error(e);
            tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--danger);">Error al cargar notas de crédito.</td></tr>`;
        }
    };

    const ncnModal = document.getElementById('newCreditNoteModal');
    const ncnForm = document.getElementById('newCreditNoteForm');
    
    window.openNewCreditNoteModal = () => {
        ncnForm.reset();
        const tasaInp = document.getElementById('cncTasa');
        if (tasaInp) tasaInp.value = window.currentTasaBCV || 0;
        ncnModal.classList.add('active');
    };
    window.closeNewCreditNoteModal = () => ncnModal.classList.remove('active');

    document.getElementById('btnNewCreditNote')?.addEventListener('click', openNewCreditNoteModal);
    document.getElementById('refreshCreditNotesBtn')?.addEventListener('click', fetchCreditNotes);
    document.getElementById('cnFilterProv')?.addEventListener('input', () => {
        clearTimeout(fetchTimeout);
        fetchTimeout = setTimeout(fetchCreditNotes, 500);
    });
    document.getElementById('cnFilterEstatus')?.addEventListener('change', fetchCreditNotes);

    ncnForm?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const btn = ncnForm.querySelector('button[type="submit"]');
        const orig = btn.innerHTML;
        btn.innerHTML = '<i class="loader" style="width:14px;height:14px;border-color:#fff;border-bottom-color:transparent;"></i>';
        btn.disabled = true;

        const rawCodProv = document.getElementById('cncCodProv').value;
        const payload = {
            CodProv: rawCodProv.split(' - ')[0],
            NumeroD: document.getElementById('cncNumeroD').value || null,
            Motivo: document.getElementById('cncMotivo').value,
            MontoBs: parseFloat(document.getElementById('cncMontoBs').value),
            Tasa: parseFloat(document.getElementById('cncTasa').value),
            Observacion: document.getElementById('cncObservacion').value
        };

        try {
            const res = await fetch('/api/procurement/credit-notes', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            if (!res.ok) throw new Error("Error al crear NC");
            showToast('✅ Solicitud de Nota de Crédito registrada.', 'success');
            closeNewCreditNoteModal();
            fetchCreditNotes();
        } catch (e) {
            showToast('❌ Error al registrar solicitud.', 'error');
        } finally {
            btn.innerHTML = orig;
            btn.disabled = false;
        }
    });

    window.anularCreditNote = async (id) => {
        if (!confirm('¿Desea anular esta solicitud de Nota de Crédito?')) return;
        try {
            const res = await fetch(`/api/procurement/credit-notes/${id}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ Estatus: 'ANULADA' })
            });
            if (!res.ok) throw new Error("Error");
            showToast('Nota de crédito anulada.', 'success');
            fetchCreditNotes();
        } catch (e) {
            showToast('Error al anular.', 'error');
        }
    };

    window.deleteCreditNote = async (id) => {
        if (!confirm('¿Está seguro de ELIMINAR PERMANENTEMENTE esta Nota de Crédito? Esta acción no se puede deshacer.')) return;
        try {
            const res = await fetch(`/api/procurement/credit-notes/${id}`, {
                method: 'DELETE'
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || "Error");
            }
            showToast('✅ Nota de crédito eliminada.', 'success');
            fetchCreditNotes();
        } catch (e) {
            showToast(`❌ Error: ${e.message}`, 'error');
        }
    };

    window.applyCreditNote = async (id) => {
        const ncId = prompt('Ingrese el Número de Nota de Crédito emitido en Saint (opcional):');
        if (ncId === null) return; // cancelled

        try {
            const res = await fetch(`/api/procurement/credit-notes/${id}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ Estatus: 'APLICADA', NotaCreditoID: ncId })
            });
            if (!res.ok) throw new Error("Error");
            showToast('✅ Nota de crédito marcada como APLICADA.', 'success');
            fetchCreditNotes();
        } catch (e) {
            showToast('Error al aplicar.', 'error');
        }
    };

    window.comprasChartInstance = null;
    const refreshComprasBtn = document.getElementById('refreshComprasBtn');
    const comprasDesde = document.getElementById('comprasDesde');
    const comprasHasta = document.getElementById('comprasHasta');

    refreshComprasBtn?.addEventListener('click', () => fetchCompras());

    const fetchCompras = async () => {
        const tbody = document.getElementById('comprasBody');
        if (!tbody) return;

        tbody.innerHTML = `<tr><td colspan="4" class="loading-cell"><div class="loader"></div><p>Cargando compras...</p></td></tr>`;
        try {
            let url = '/api/reports/compras';
            const params = new URLSearchParams();
            if (comprasDesde && comprasDesde.value) params.append('desde', comprasDesde.value);
            if (comprasHasta && comprasHasta.value) params.append('hasta', comprasHasta.value);
            if (params.toString()) url += '?' + params.toString();

            const res = await fetch(url);
            const { data } = await res.json();

            if (!data.length) {
                tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--text-secondary);">No hay datos.</td></tr>`;
                if (window.comprasChartInstance) window.comprasChartInstance.destroy();
                return;
            }

            renderComprasChart(data.slice(0, 10)); // Mostrar top 10 en gráfico

            tbody.innerHTML = data.map(item => `
                <tr>
                    <td style="font-weight: 500;">${item.Proveedor || '-'}</td>
                    <td class="amount" style="font-weight: bold;">${usdFormatter(item.TotalUSD)}</td>
                    <td class="amount" style="color: var(--primary-accent);">${item.Porcentaje.toFixed(2)}%</td>
                    <td class="amount">${item.CantidadFacturas}</td>
                </tr>
            `).join('');
            lucide.createIcons();
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    const renderComprasChart = (data) => {
        const ctx = document.getElementById('comprasChart').getContext('2d');
        if (window.comprasChartInstance) window.comprasChartInstance.destroy();

        const labels = data.map(i => i.Proveedor.substring(0, 15) + '...');
        const amounts = data.map(i => i.TotalUSD);

        window.comprasChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Monto Total Compras (USD)',
                    data: amounts,
                    backgroundColor: 'rgba(59, 130, 246, 0.7)',
                    borderColor: '#3b82f6',
                    borderWidth: 1,
                    borderRadius: 4
                }]
            },
            options: {
                indexAxis: 'y', // Grafico horizontal para mejor lectura de nombres
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: { grid: { color: 'rgba(255, 255, 255, 0.05)' }, ticks: { color: '#94a3b8' } },
                    y: { grid: { display: false }, ticks: { color: '#f8fafc' } }
                }
            }
        });
    };

    const fetchAging = async () => {
        const tbody = document.getElementById('agingBody');
        tbody.innerHTML = `<tr><td colspan="7" class="loading-cell"><div class="loader"></div><p>Cargando antigüedad en USD...</p></td></tr>`;
        try {
            const res = await fetch('/api/reports/aging');
            const { data } = await res.json();
            if (!data.length) {
                tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-secondary);">No hay datos.</td></tr>`;
                return;
            }

            // Calculate summaries
            const sumPorVencer = data.reduce((acc, curr) => acc + (curr.PorVencer || 0), 0);
            const sum1_30 = data.reduce((acc, curr) => acc + (curr.Dias_1_30 || 0), 0);
            const sum31_60 = data.reduce((acc, curr) => acc + (curr.Dias_31_60 || 0), 0);
            const sum61_90 = data.reduce((acc, curr) => acc + (curr.Dias_61_90 || 0), 0);
            const sumMas90 = data.reduce((acc, curr) => acc + (curr.Mas_90 || 0), 0);
            const sumTotal = data.reduce((acc, curr) => acc + (curr.Total || 0), 0);

            // Update summary DOM
            if (document.getElementById('agingSummaryPorVencer')) document.getElementById('agingSummaryPorVencer').innerText = usdFormatter(sumPorVencer);
            if (document.getElementById('agingSummary1_30')) document.getElementById('agingSummary1_30').innerText = usdFormatter(sum1_30);
            if (document.getElementById('agingSummary31_60')) document.getElementById('agingSummary31_60').innerText = usdFormatter(sum31_60);
            if (document.getElementById('agingSummary61_90')) document.getElementById('agingSummary61_90').innerText = usdFormatter(sum61_90);
            if (document.getElementById('agingSummaryMas90')) document.getElementById('agingSummaryMas90').innerText = usdFormatter(sumMas90);
            if (document.getElementById('agingSummaryTotal')) document.getElementById('agingSummaryTotal').innerText = usdFormatter(sumTotal);

            tbody.innerHTML = data.map(item => `
            <tr>
                <td style="font-weight: 500;">${item.Proveedor || '-'}</td>
                <td class="amount us-amount">${usdFormatter(item.PorVencer)}</td>
                <td class="amount us-amount" style="color: #eab308;">${usdFormatter(item.Dias_1_30)}</td>
                <td class="amount us-amount" style="color: #f97316;">${usdFormatter(item.Dias_31_60)}</td>
                <td class="amount us-amount" style="color: #ef4444;">${usdFormatter(item.Dias_61_90)}</td>
                <td class="amount us-amount" style="color: #b91c1c; font-weight: bold;">${usdFormatter(item.Mas_90)}</td>
                <td class="amount us-amount" style="font-weight: bold;">${usdFormatter(item.Total)}</td>
            </tr>
        `).join('');
        } catch (e) {
            console.error("fetchAging error:", e);
            tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    window.cashflowChartInstance = null;

    const renderCashflowChart = (data) => {
        const ctx = document.getElementById('cashflowChart').getContext('2d');
        if (window.cashflowChartInstance) {
            window.cashflowChartInstance.destroy();
        }

        const labels = data.map(i => i.Periodo);
        const facturasUsd = data.map(i => Math.round(i.FacturasUSD || 0));
        const gastosFijosUsd = data.map(i => Math.round(i.GastosFijosUSD || 0));
        const gastosPersonalesUsd = data.map(i => Math.round(i.GastosPersonalesUSD || 0));

        const totalsUsd = data.map(i => Math.round(i.SaldoProyectadoUSD || 0));

        window.cashflowChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Pagos Proveedores',
                        data: facturasUsd,
                        backgroundColor: 'rgba(34, 197, 94, 0.7)',
                        borderColor: '#22c55e',
                        borderWidth: 1,
                        borderRadius: { topLeft: 0, topRight: 0, bottomLeft: 4, bottomRight: 4 }
                    },
                    {
                        label: 'Gastos Fijos',
                        data: gastosFijosUsd,
                        backgroundColor: 'rgba(251, 146, 60, 0.7)',
                        borderColor: '#fb923c',
                        borderWidth: 1,
                        borderRadius: 0
                    },
                    {
                        label: 'Gastos Personales',
                        data: gastosPersonalesUsd,
                        backgroundColor: 'rgba(192, 38, 211, 0.7)',
                        borderColor: '#c026d3',
                        borderWidth: 1,
                        borderRadius: { topLeft: 4, topRight: 4, bottomLeft: 0, bottomRight: 0 }
                    }
                ]
            },
            options: {
                layout: {
                    padding: { top: 25 }
                },
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        labels: { color: '#f8fafc', font: { family: 'Inter', size: 13 } }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            label: function (context) {
                                let label = context.dataset.label || '';
                                if (label) label += ': ';
                                if (context.parsed.y !== null) {
                                    label += context.parsed.y + ' USD';
                                }
                                return label;
                            }
                        }
                    }
                },
                scales: {
                    x: { stacked: true, grid: { color: 'rgba(255, 255, 255, 0.05)' } },
                    y: {
                        stacked: true,
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        ticks: {
                            callback: function (value) {
                                return value >= 1000 ? (value / 1000).toFixed(0) + 'k' : value;
                            }
                        }
                    }
                },
                color: '#94a3b8'
            },
            plugins: [{
                id: 'topLabels',
                afterDatasetsDraw(chart) {
                    const ctx = chart.ctx;
                    ctx.fillStyle = '#f8fafc';
                    ctx.font = 'bold 12px Inter';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'bottom';

                    const padding = 5;
                    const metaKeys = chart.data.datasets.map((_, i) => i);

                    labels.forEach((_, index) => {
                        let total = totalsUsd[index];
                        if (total > 0) {
                            // Find the topmost visible rectangle for this index
                            let highestY = chart.chartArea.bottom;
                            metaKeys.forEach(dsIndex => {
                                const meta = chart.getDatasetMeta(dsIndex);
                                if (!meta.hidden && meta.data[index]) {
                                    const yPos = meta.data[index].y;
                                    if (yPos < highestY) { highestY = yPos; }
                                }
                            });

                            const xPos = chart.getDatasetMeta(0).data[index].x;
                            const dataString = Number(total).toLocaleString('de-DE') + ' $';
                            ctx.fillText(dataString, xPos, highestY - padding);
                        }
                    });
                }
            }]
        });
    };


    const fetchCashflow = async () => {
        const tbody = document.getElementById('cashflowBody');
        tbody.innerHTML = `<tr><td colspan="3" class="loading-cell"><div class="loader"></div><p>Cargando pronóstico...</p></td></tr>`;

        // Initialize 22-day default range (-7 to +14) if empty
        if (!cashflowDateDesde.value && !cashflowDateHasta.value) {
            const today = new Date();
            const past7 = new Date(today);
            past7.setDate(today.getDate() - 7);
            const future14 = new Date(today);
            future14.setDate(today.getDate() + 14);

            cashflowDateDesde.value = past7.toISOString().split('T')[0];
            cashflowDateHasta.value = future14.toISOString().split('T')[0];
        }

        try {
            let url = '/api/reports/cashflow';
            const params = new URLSearchParams();
            if (cashflowDateDesde.value) params.append('desde', cashflowDateDesde.value);
            if (cashflowDateHasta.value) params.append('hasta', cashflowDateHasta.value);

            if (params.toString()) {
                url += '?' + params.toString();
            }

            const res = await fetch(url);
            const { data } = await res.json();
            if (!data.length) {
                tbody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--text-secondary);">No hay datos en el rango seleccionado.</td></tr>`;
                if (window.cashflowChartInstance) window.cashflowChartInstance.destroy();
                document.getElementById('cashflowUsdTotal').textContent = "";
                return;
            }

            // Render Chart
            renderCashflowChart(data);

            // Compute Grand Total USD
            const totalUsd = data.reduce((sum, item) => sum + (parseFloat(item.SaldoProyectadoUSD) || 0), 0);
            document.getElementById('cashflowUsdTotal').innerHTML = `Deuda Total en USD (Rango): <span style="color: #22c55e;">${usdFormatter(totalUsd)}</span>`;

            // Populate Table
            const todayStr = new Date().toISOString().split('T')[0];

            tbody.innerHTML = data.map(item => {
                const isToday = item.Periodo === todayStr;
                const highlightStyle = isToday ? 'background: rgba(234, 179, 8, 0.15); border-left: 3px solid #eab308;' : '';
                const dateLabel = isToday ? `${item.Periodo || '-'} <span style="font-size: 0.75rem; background: #eab308; color: #0f172a; padding: 2px 6px; border-radius: 4px; margin-left: 8px;">HOY</span>` : (item.Periodo || '-');

                return `
                <tr style="${highlightStyle}">
                    <td style="font-weight: 500;">${dateLabel}</td>
                    <td class="amount" style="color: #22c55e;">${usdFormatter(item.FacturasUSD)}</td>
                    <td class="amount" style="color: #fb923c;">${usdFormatter(item.GastosFijosUSD)}</td>
                    <td class="amount" style="color: #c026d3;">${usdFormatter(item.GastosPersonalesUSD)}</td>
                    <td class="amount us-amount" style="font-weight: bold;">${usdFormatter(item.SaldoProyectadoUSD)}</td>
                </tr>
            `}).join('');
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="2" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    const fetchDpo = async () => {
        const tbody = document.getElementById('dpoBody');
        tbody.innerHTML = `<tr><td colspan="3" class="loading-cell"><div class="loader"></div><p>Cargando DPO...</p></td></tr>`;
        try {
            const res = await fetch('/api/reports/dpo');
            const { data } = await res.json();
            if (!data.length) {
                tbody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--text-secondary);">No hay datos.</td></tr>`;
                return;
            }
            tbody.innerHTML = data.map(item => `
                <tr>
                    <td style="font-weight: 500;">${item.Periodo || '-'}</td>
                    <td class="amount">${Number(item.PromedioDiasPago).toFixed(1)} Días</td>
                    <td class="amount">${item.FacturasPagadas} Facturas</td>
                </tr>
            `).join('');
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    // Boot
    fetchData();

    // ==========================================
    // FORECAST MODULE: Sales, Consolidated, Events
    // ==========================================

    window.forecastSalesChartInstance = null;
    window.forecastConsChartInstance = null;

    // --- FORECAST SALES ---
    refreshForecastSalesBtn?.addEventListener('click', () => fetchForecastSales());

    const fetchForecastSales = async () => {
        const tbody = document.getElementById('forecastSalesBody');
        if (!tbody) return;

        tbody.innerHTML = `<tr><td colspan="3" class="loading-cell"><div class="loader"></div><p>Cargando pronóstico...</p></td></tr>`;

        if (!getDateValue(fsDateDesde) && !getDateValue(fsDateHasta)) {
            const today = new Date();
            const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
            const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
            setDateValue(fsDateDesde, firstDay.toISOString().split('T')[0]);
            setDateValue(fsDateHasta, lastDay.toISOString().split('T')[0]);
        }

        try {
            let url = '/api/reports/forecast-sales';
            const params = new URLSearchParams();
            const d1 = getDateValue(fsDateDesde);
            const d2 = getDateValue(fsDateHasta);
            if (d1) params.append('desde', d1);
            if (d2) params.append('hasta', d2);
            if (params.toString()) url += '?' + params.toString();

            const res = await fetch(url);
            if (!res.ok) throw new Error("Error loading");
            const { data } = await res.json();

            if (!data.length) {
                tbody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--text-secondary);">No hay datos en el rango seleccionado.</td></tr>`;
                if (window.forecastSalesChartInstance) window.forecastSalesChartInstance.destroy();
                document.getElementById('forecastSalesUsdTotal').textContent = "";
                return;
            }

            renderForecastSalesChart(data);

            const totalUsd = data.reduce((sum, item) => sum + (parseFloat(item.VentasProyectadasUSD) || 0), 0);
            document.getElementById('forecastSalesUsdTotal').innerHTML = `Ventas Totales Proyectadas (USD): <span style="color: #22c55e;">${usdFormatter(totalUsd)}</span>`;

            tbody.innerHTML = data.map(item => `
                <tr>
                    <td style="font-weight: 500;">${item.Periodo}</td>
                    <td class="amount" style="font-weight: bold; color: var(--text-primary);">${formatBs(item.VentasProyectadas)}</td>
                    <td class="amount us-amount" style="font-weight: bold;">${usdFormatter(item.VentasProyectadasUSD)}</td>
                </tr>
            `).join('');
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    const renderForecastSalesChart = (data) => {
        const ctx = document.getElementById('forecastSalesChart').getContext('2d');
        if (window.forecastSalesChartInstance) window.forecastSalesChartInstance.destroy();

        const labels = data.map(i => i.Periodo);
        const amountsUsd = data.map(i => Math.round(i.VentasProyectadasUSD || 0));

        window.forecastSalesChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Ventas Proyectadas (USD)',
                    data: amountsUsd,
                    backgroundColor: 'rgba(34, 197, 94, 0.7)',
                    borderColor: '#22c55e',
                    borderWidth: 1,
                    borderRadius: 4
                }]
            },
            options: {
                layout: { padding: { top: 25 } },
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: true, labels: { color: '#f8fafc', font: { family: 'Inter', size: 13 } } }
                },
                scales: {
                    x: { grid: { color: 'rgba(255, 255, 255, 0.05)' } },
                    y: { grid: { color: 'rgba(255, 255, 255, 0.05)' } }
                },
                color: '#94a3b8'
            }
        });
    };

    // --- FORECAST CONSOLIDATED ---
    refreshForecastConsolidatedBtn?.addEventListener('click', () => fetchForecastConsolidated());

    const fetchForecastConsolidated = async () => {
        const tbody = document.getElementById('forecastConsolidatedBody');
        if (!tbody) return;

        tbody.innerHTML = `<tr><td colspan="7" class="loading-cell"><div class="loader"></div><p>Cargando consolidado en vivo...</p></td></tr>`;

        // Default 21 days view if empty
        if (!getDateValue(fcDateDesde) && !getDateValue(fcDateHasta)) {
            const today = new Date();
            const future21 = new Date(today);
            future21.setDate(today.getDate() + 21);
            setDateValue(fcDateDesde, today.toISOString().split('T')[0]);
            setDateValue(fcDateHasta, future21.toISOString().split('T')[0]);
        }

        try {
            // Apply new settings from UI/Local Store
            const saved = JSON.parse(localStorage.getItem('cashflowParams') || '{}');
            const fechaCero = saved.fechaCero || new Date().toISOString().split('T')[0];
            const cajaUsd = saved.cajaUsd || 0;
            const cajaBs = saved.cajaBs || 0;
            const delayDays = saved.toggleDelay ? (saved.retardoDays || 1) : 0;

            let url = `/api/reports/forecast-consolidated?fecha_arranque=${fechaCero}&caja_usd=${cajaUsd}&caja_bs=${cajaBs}&delay_days=${delayDays}`;

            if (getDateValue(fcDateDesde)) url += `&desde=${getDateValue(fcDateDesde)}`;
            if (getDateValue(fcDateHasta)) url += `&hasta=${getDateValue(fcDateHasta)}`;

            const res = await fetch(url);
            if (!res.ok) throw new Error("Error loading flow");
            const { data } = await res.json();

            if (!data || !data.length) {
                tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-secondary);">No hay datos en el rango. Asegúrese de que la 'Fecha de Arranque' sea anterior a las fechas consultadas.</td></tr>`;
                if (window.forecastConsChartInstance) window.forecastConsChartInstance.destroy();
                return;
            }

            renderForecastConsolidatedChart(data);

            const todayStr = new Date().toISOString().split('T')[0];

            tbody.innerHTML = data.map(item => {
                const isPositive = item.SaldoRealCajaUSD >= 0;
                const statusColor = isPositive ? 'color: var(--success);' : 'color: var(--danger);';
                // Flujo Neto = Entradas - Salidas (Total USD)
                const flujoNeto = (parseFloat(item.EntradasUSD) || 0) - (parseFloat(item.SalidasPagosUSD) || 0) - (parseFloat(item.SalidasFarmaciaUSD) || 0) - (parseFloat(item.SalidasPersonalesUSD) || 0);
                const flujoNetoColor = flujoNeto >= 0 ? 'color: var(--success);' : 'color: var(--danger);';

                const isToday = item.Periodo === todayStr;
                const formattedDateStr = formatDate(item.Periodo);
                const highlightStyle = isToday ? 'background: rgba(234, 179, 8, 0.15); border-left: 3px solid #eab308;' : '';
                const dateLabel = isToday ? `${formattedDateStr} <span style="font-size: 0.75rem; background: #eab308; color: #0f172a; padding: 2px 6px; border-radius: 4px; margin-left: 8px;">HOY</span>` : formattedDateStr;

                return `
                <tr style="${highlightStyle}">
                    <td style="font-weight: 500;">${dateLabel}</td>
                    <td class="amount us-amount" style="color:var(--text-primary)">${usdFormatter(item.EntradasUSD)}</td>
                    <td class="amount us-amount" style="color:var(--danger)">${usdFormatter(item.SalidasPagosUSD)}</td>
                    <td class="amount us-amount" style="color:#fb923c">${usdFormatter(item.SalidasFarmaciaUSD)}</td>
                    <td class="amount us-amount" style="color:#c026d3">${usdFormatter(item.SalidasPersonalesUSD)}</td>
                    <td class="amount us-amount" style="${flujoNetoColor}">${usdFormatter(flujoNeto)}</td>
                    <td class="amount us-amount" style="${statusColor} font-weight: bold; background: rgba(0,0,0,0.2);">${usdFormatter(item.SaldoRealCajaUSD)}</td>
                </tr>
            `}).join('');
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    const renderForecastConsolidatedChart = (data) => {
        const ctx = document.getElementById('forecastConsolidatedChart').getContext('2d');
        if (window.forecastConsChartInstance) window.forecastConsChartInstance.destroy();

        const labels = data.map(i => formatDate(i.Periodo));
        const entradasUsd = data.map(i => Math.round(i.EntradasUSD || 0));
        const salidasFacturasUsd = data.map(i => -Math.round(i.SalidasPagosUSD || 0));
        const gastosFijosUsd = data.map(i => -Math.round(i.SalidasFarmaciaUSD || 0));
        const gastosPersonalesUsd = data.map(i => -Math.round(i.SalidasPersonalesUSD || 0));
        const acumuladoUsd = data.map(i => Math.round(i.SaldoRealCajaUSD || 0));

        window.forecastConsChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        type: 'line',
                        label: 'Saldo Acumulado Real (Dólares Netos)',
                        data: acumuladoUsd,
                        borderColor: '#10b981', // green success
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.3,
                        yAxisID: 'y'
                    },
                    {
                        type: 'bar',
                        label: 'Ingresos (Ventas)',
                        data: entradasUsd,
                        backgroundColor: 'rgba(34, 197, 94, 0.7)',
                        stack: 'ingresos',
                        yAxisID: 'y'
                    },
                    {
                        type: 'bar',
                        label: 'Egresos (Pagos Proveedores)',
                        data: salidasFacturasUsd,
                        backgroundColor: 'rgba(239, 68, 68, 0.7)', // red
                        stack: 'egresos',
                        yAxisID: 'y'
                    },
                    {
                        type: 'bar',
                        label: 'Gastos Farmacia',
                        data: gastosFijosUsd,
                        backgroundColor: 'rgba(251, 146, 60, 0.7)', // orange
                        stack: 'egresos',
                        yAxisID: 'y'
                    },
                    {
                        type: 'bar',
                        label: 'Gastos Personales (Dueños)',
                        data: gastosPersonalesUsd,
                        backgroundColor: 'rgba(192, 38, 211, 0.7)', // rose/pink
                        stack: 'egresos',
                        yAxisID: 'y'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: true, labels: { color: '#f8fafc' } },
                    tooltip: { mode: 'index', intersect: false }
                },
                scales: {
                    x: {
                        stacked: true,
                        grid: { color: 'rgba(255, 255, 255, 0.05)' }
                    },
                    y: {
                        stacked: true,
                        grid: { color: 'rgba(255, 255, 255, 0.05)' }
                    }
                },
                color: '#94a3b8'
            }
        });
    };

    // --- FORECAST EVENTS (CRUD) ---
    const addEventBtn = document.getElementById('addEventBtn');
    addEventBtn?.addEventListener('click', async () => {
        const fecha = getDateValue(document.getElementById('eventFecha'));
        const tipo = document.getElementById('eventTipo').value;
        const valor = parseFloat(document.getElementById('eventValor').value);

        if (!fecha || !tipo || isNaN(valor)) {
            alert('Por favor complete todos los campos');
            return;
        }

        try {
            addEventBtn.disabled = true;
            addEventBtn.innerHTML = '<i data-lucide="loader" class="spin"></i> Guardando...';

            const res = await fetch('/api/forecast-events', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ fecha, tipo_evento: tipo, valor })
            });
            if (!res.ok) throw new Error('Failed to save');

            setDateValue(document.getElementById('eventFecha'), '');

            document.getElementById('eventValor').value = '1.0';
            fetchForecastEvents();
        } catch (e) {
            alert('Error al guardar el evento.');
        } finally {
            addEventBtn.disabled = false;
            addEventBtn.innerHTML = '<i data-lucide="plus"></i> Añadir Evento';
            lucide.createIcons();
        }
    });

    const fetchForecastEvents = async () => {
        const tbody = document.getElementById('forecastEventsBody');
        if (!tbody) return;

        tbody.innerHTML = `<tr><td colspan="5" class="loading-cell"><div class="loader"></div><p>Cargando eventos...</p></td></tr>`;
        try {
            const res = await fetch('/api/forecast-events');
            const { data } = await res.json();
            if (!data.length) {
                tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--text-secondary);">No hay eventos registrados.</td></tr>`;
                return;
            }
            tbody.innerHTML = data.map(item => `
                <tr>
                    <td>${item.id}</td>
                    <td style="font-weight: 500;">${item.fecha}</td>
                    <td><span class="status-badge" style="background: rgba(168,85,247,0.1); color: #a855f7;">${item.tipo_evento}</span></td>
                    <td>${item.valor}</td>
                    <td>
                        <button class="btn-icon text-danger" onclick="deleteForecastEvent(${item.id})">
                            <i data-lucide="trash-2"></i>
                        </button>
                    </td>
                </tr>
            `).join('');
            lucide.createIcons();
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--danger);">Error al cargar.</td></tr>`;
        }
    };

    window.deleteForecastEvent = async (id) => {
        if (!confirm('¿Seguro que desea eliminar este evento?')) return;
        try {
            const res = await fetch(`/api/forecast-events/${id}`, { method: 'DELETE' });
            if (!res.ok) throw new Error('Failed to delete');
            fetchForecastEvents();
        } catch (e) {
            alert('Error al eliminar.');
        }
    };

    // --- GASTOS PROGRAMADOS (PLANTILLAS Y BATCH) ---

    // Plantillas de Gastos
    window.expenseTemplatesData = [];
    window.renderExpenseTemplates = () => {
        const tbody = document.getElementById('expenseTemplatesBody');
        if (!tbody) return;
        if (!window.expenseTemplatesData.length) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--text-secondary);">No hay plantillas creadas.</td></tr>`;
            return;
        }
        tbody.innerHTML = window.expenseTemplatesData.map(t => `
            <tr>
                <td style="font-weight: 500;">${t.descripcion}</td>
                <td><span class="status-badge" style="background: ${t.tipo === 'Farmacia' ? 'rgba(251, 146, 60, 0.1)' : 'rgba(192, 38, 211, 0.1)'}; color: ${t.tipo === 'Farmacia' ? '#fb923c' : '#c026d3'};">${t.tipo}</span></td>
                <td class="amount">${usdFormatter(t.monto_usd)}</td>
                <td class="amount">Día ${t.dia_mes_estimado}</td>
                <td class="amount">
                    <button class="btn-icon text-primary" onclick="editExpenseTpl(${t.id}, '${t.descripcion.replace(/'/g, "\\'")}', '${t.tipo}', ${t.monto_usd}, ${t.dia_mes_estimado})">
                        <i data-lucide="edit"></i>
                    </button>
                    <button class="btn-icon text-danger" onclick="deleteExpenseTpl(${t.id})">
                        <i data-lucide="trash-2"></i>
                    </button>
                </td>
            </tr>
        `).join('');
        lucide.createIcons();
    };

    const fetchExpenseTemplates = async () => {
        const tbody = document.getElementById('expenseTemplatesBody');
        if (!tbody) return;
        tbody.innerHTML = `<tr><td colspan="5" class="loading-cell"><div class="loader"></div><p>Cargando plantillas...</p></td></tr>`;
        try {
            const res = await fetch('/api/expense-templates');
            const { data } = await res.json();
            window.expenseTemplatesData = data || [];
            window.renderExpenseTemplates();
        } catch (e) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--danger);">Error.</td></tr>`;
        }
    };

    const expenseTplModal = document.getElementById('expenseTplModal');
    window.showExpenseTplModal = () => {
        document.getElementById('expenseTplForm').reset();
        document.getElementById('tplId').value = '';
        document.getElementById('expenseTplModalTitle').innerText = 'Nueva Plantilla de Gasto';
        expenseTplModal.classList.add('active');
    };
    window.closeExpenseTplModal = () => expenseTplModal.classList.remove('active');

    window.editExpenseTpl = (id, desc, tipo, monto, dia) => {
        document.getElementById('tplId').value = id;
        document.getElementById('tplDesc').value = desc;
        document.getElementById('tplTipo').value = tipo;
        document.getElementById('tplMonto').value = monto;
        document.getElementById('tplDia').value = dia;
        document.getElementById('expenseTplModalTitle').innerText = 'Editar Plantilla';
        expenseTplModal.classList.add('active');
    };

    document.getElementById('expenseTplForm')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const id = document.getElementById('tplId').value;
        const payload = {
            id: id ? parseInt(id) : null,
            descripcion: document.getElementById('tplDesc').value,
            tipo: document.getElementById('tplTipo').value,
            monto_estimado_usd: parseFloat(document.getElementById('tplMonto').value),
            dia_mes_estimado: parseInt(document.getElementById('tplDia').value)
        };
        try {
            await fetch('/api/expense-templates', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            closeExpenseTplModal();
            fetchExpenseTemplates();
        } catch (err) { alert('Error al guardar plantilla'); }
    });

    window.deleteExpenseTpl = async (id) => {
        if (!confirm('¿Eliminar plantilla? Todos los próximos cálculos la omitirán, pero los lotes ya guardados seguirán iguales.')) return;
        try {
            await fetch(`/api/expense-templates/${id}`, { method: 'DELETE' });
            fetchExpenseTemplates();
        } catch (e) { alert('Error al eliminar'); }
    };

    // Lotes Modificables
    window.currentBatchData = [];
    window.generateExpenseBatch = async () => {
        const mes = document.getElementById('batchMes').value;
        const anio = document.getElementById('batchAnio').value;
        if (!mes || !anio) return alert("Seleccione Mes y Año válidos.");

        document.getElementById('saveBatchBtn').style.display = 'inline-flex';
        document.getElementById('batchSection').style.display = 'block';

        const tbodyFijos = document.getElementById('expenseBatchBodyFijos');
        const tbodyAdhoc = document.getElementById('expenseBatchBodyAdhoc');
        tbodyFijos.innerHTML = `<tr><td colspan="5" class="loading-cell"><div class="loader"></div><p>Generando simulación...</p></td></tr>`;
        tbodyAdhoc.innerHTML = '';

        try {
            const res = await fetch(`/api/expenses/generate-batch/${mes}/${anio}`);
            const { data } = await res.json();

            // Assign isAdhoc flag
            window.currentBatchData = data.map(d => ({ ...d, isAdhoc: false }));

            if (!data.length) {
                tbodyFijos.innerHTML = `<tr><td colspan="5" style="text-align: center;">No hay plantillas para generar. Registre plantillas primero.</td></tr>`;
                document.getElementById('saveBatchBtn').style.display = 'none';
                return;
            }

            renderBatchTable();
            fetchSavedBatch();
        } catch (e) { tbodyFijos.innerHTML = `<tr><td colspan="5" class="text-danger">Error al generar.</td></tr>`; }
    };

    window.renderBatchTable = () => {
        const tbodyFijos = document.getElementById('expenseBatchBodyFijos');
        const tbodyAdhoc = document.getElementById('expenseBatchBodyAdhoc');

        const rowTemplate = (t, idx) => `
            <tr>
                <td style="text-align: center; vertical-align: middle;">
                    ${t.isAdhoc ?
                `<button class="btn btn-primary btn-sm" onclick="saveSingleAdhocExpense(${idx})" style="padding: 2px 6px;"><i data-lucide="check"></i> Guardar</button>`
                : `<input type="checkbox" class="batch-checkbox form-control" style="width: 18px; height: 18px; cursor: pointer; display: inline-block; margin: 0;" data-index="${idx}" checked>`
            }
                </td>
                <td style="font-weight: 500;">
                    <input type="text" class="form-control" style="background:#1e293b; color:var(--text-primary); border:1px solid #334155; padding:0.25rem 0.5rem;" 
                    value="${t.descripcion}" oninput="window.currentBatchData[${idx}].descripcion=this.value" placeholder="Descripción...">
                </td>
                <td>
                    <select class="form-control" style="background:#1e293b; color:${t.tipo === 'Farmacia' ? '#fb923c' : '#c026d3'}; border:1px solid #334155; padding:0.25rem 0.5rem; width: 140px;" onchange="window.currentBatchData[${idx}].tipo=this.value; renderBatchTable()">
                        <option value="Farmacia" style="color: #fb923c;" ${t.tipo === 'Farmacia' ? 'selected' : ''}>Farmacia</option>
                        <option value="Personal" style="color: #c026d3;" ${t.tipo === 'Personal' ? 'selected' : ''}>Personal</option>
                    </select>
                </td>
                <td class="amount">
                     <input type="number" class="form-control" step="0.01" style="width:100px; display:inline-block; background:#1e293b; color:var(--text-primary); border:1px solid #334155; padding:0.25rem 0.5rem;" 
                    value="${t.monto_usd}" oninput="window.currentBatchData[${idx}].monto_usd=parseFloat(this.value)">
                </td>
                <td class="amount">
                     <input type="date" class="form-control" style="width:130px; display:inline-block; background:#1e293b; color:var(--text-primary); border:1px solid #334155; padding:0.25rem 0.5rem;" 
                    value="${t.fecha_proyectada}" oninput="window.updateBatchDate(${idx}, this)">
                </td>
            </tr>
        `;

        tbodyFijos.innerHTML = window.currentBatchData.map((t, idx) => !t.isAdhoc ? rowTemplate(t, idx) : '').join('');
        tbodyAdhoc.innerHTML = window.currentBatchData.map((t, idx) => t.isAdhoc ? rowTemplate(t, idx) : '').join('');

        // Apply formatting trick to newly generated inputs
        document.querySelectorAll('#expenseBatchTableFijos input[type="date"], #expenseBatchTableAdhoc input[type="date"]').forEach(el => setupDateInput(el));

        if (tbodyAdhoc.innerHTML.trim() === '') {
            tbodyAdhoc.innerHTML = `<tr><td colspan="5" style="text-align: center; color: #64748b;">No hay gastos variables añadidos.</td></tr>`;
        }
        lucide.createIcons();
    };

    window.updateBatchDate = (idx, el) => {
        window.currentBatchData[idx].fecha_proyectada = getDateValue(el);
    };

    window.saveExpenseBatch = async () => {
        if (!confirm("Advertencia: Se guardará este lote. Si ya existía un lote de gastos para este mes y año, se reemplazará por completo. ¿Deseas hacer el commit?")) return;

        const mes = parseInt(document.getElementById('batchMes').value);
        const anio = parseInt(document.getElementById('batchAnio').value);

        // Filter only checked items
        const checkboxes = document.querySelectorAll('.batch-checkbox');
        const selectedGastos = [];
        checkboxes.forEach((cb) => {
            if (cb.checked) {
                const idx = parseInt(cb.getAttribute('data-index'));
                selectedGastos.push(window.currentBatchData[idx]);
            }
        });

        if (selectedGastos.length === 0) {
            return alert("Debe seleccionar al menos un gasto para guardar.");
        }

        try {
            const res = await fetch('/api/expenses/batch', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ mes, anio, gastos: selectedGastos })
            });
            if (!res.ok) throw new Error('Error de servidor al guardar lote');
            alert("Lote guardado exitosamente en la base de datos de Pronósticos.");
            fetchSavedBatch();
        } catch (e) { alert("Error al guardar Lote"); }
    };

    window.saveSingleAdhocExpense = async (idx) => {
        const item = window.currentBatchData[idx];
        if (!item.descripcion || item.monto_usd <= 0) return alert("Ingrese descripción y un monto mayor a 0.");

        try {
            const res = await fetch('/api/expenses/programmed/single', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(item)
            });
            if (!res.ok) throw new Error('Error de servidor al guardar variable');
            // Remove the ad-hoc row from the UI
            window.currentBatchData.splice(idx, 1);
            renderBatchTable();
            fetchSavedBatch();
        } catch (e) { alert("Error al guardar gasto variable"); }
    };

    window.addAdhocExpense = () => {
        document.getElementById('saveBatchBtn').style.display = 'inline-flex';
        document.getElementById('batchSection').style.display = 'block';

        const anio = document.getElementById('batchAnio').value || new Date().getFullYear();
        let mes = document.getElementById('batchMes').value || (new Date().getMonth() + 1);
        mes = mes.toString().padStart(2, '0');

        window.currentBatchData.push({
            descripcion: '',
            tipo: 'Farmacia',
            monto_usd: 0,
            fecha_proyectada: `${anio}-${mes}-15`,
            estado: 'Pendiente',
            isAdhoc: true
        });
        window.renderBatchTable();
    };

    // Gastos ya guardados del mes seleccionado
    window.expenseSavedBatchData = [];
    window.renderSavedBatchTable = () => {
        const tbody = document.getElementById('expenseSavedBatchBody');
        const searchInput = document.getElementById('expenseSavedBatchSearch');
        if (!tbody) return;

        let filteredData = window.expenseSavedBatchData;
        if (searchInput && searchInput.value) {
            const query = searchInput.value.toLowerCase();
            filteredData = filteredData.filter(t => t.descripcion.toLowerCase().includes(query));
        }

        if (!filteredData.length) {
            if (window.expenseSavedBatchData.length) {
                tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; color: var(--text-secondary);">No hay resultados para la búsqueda.</td></tr>`;
            } else {
                tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; color: var(--text-secondary);">El mes está limpio en la base de datos.</td></tr>`;
            }
            return;
        }
        tbody.innerHTML = filteredData.map(t => `
            <tr>
                <td style="font-weight: 500;">${t.descripcion}</td>
                <td><span class="status-badge" style="background: ${t.tipo === 'Farmacia' ? 'rgba(251, 146, 60, 0.1)' : 'rgba(192, 38, 211, 0.1)'}; color: ${t.tipo === 'Farmacia' ? '#fb923c' : '#c026d3'};">${t.tipo}</span></td>
                <td class="amount">${usdFormatter(t.monto_usd)}</td>
                <td class="amount">${formatDate(t.fecha_proyectada)}</td>
                <td class="amount"><span class="status-badge">${t.estado}</span></td>
                <td class="amount">
                    <button class="btn-icon text-danger" onclick="deleteSavedExpense(${t.id})">
                        <i data-lucide="trash-2"></i>
                    </button>
                </td>
            </tr>
        `).join('');
        lucide.createIcons();
    };

    const fetchSavedBatch = async () => {
        const mes = document.getElementById('batchMes').value;
        const anio = document.getElementById('batchAnio').value;
        const tbody = document.getElementById('expenseSavedBatchBody');
        if (!tbody || !mes || !anio) return;

        try {
            const res = await fetch(`/api/expenses/programmed?mes=${mes}&anio=${anio}`);
            const { data } = await res.json();
            window.expenseSavedBatchData = data || [];
            window.renderSavedBatchTable();
        } catch (e) { tbody.innerHTML = `<tr><td colspan="6" class="text-danger">Error.</td></tr>`; }
    }

    window.deleteSavedExpense = async (id) => {
        if (!confirm('¿Eliminar definitivamente ente gasto del mes?')) return;
        try {
            await fetch(`/api/expenses/programmed/${id}`, { method: 'DELETE' });
            fetchSavedBatch();

            // Force refresh of flow dashboard if user returns
            if (window.forecastConsChartInstance) {
                window.forecastConsChartInstance.destroy();
                window.forecastConsChartInstance = null;
            }
            if (document.querySelector('.view-section.active')?.id === 'view-forecast-consolidated') {
                fetchForecastConsolidated();
            }
        } catch (e) { alert('Error al eliminar'); }
    };

    // Auto-Set de Mes y Año en Batch y Cargar Lotes Previos
    const dateObj = new Date();
    const meshp = document.getElementById('batchMes');
    const aniohp = document.getElementById('batchAnio');
    if (meshp) {
        meshp.value = dateObj.getMonth() + 1;
        meshp.addEventListener('change', fetchSavedBatch);
    }
    if (aniohp) {
        // aniohp.value is already set to 2026/2027 in HTML usually, but we ensure listeners
        aniohp.addEventListener('change', fetchSavedBatch);
    }

    // ----- Módulo de Proveedores (Condiciones de Indexación) -----
    let providersData = [];

    window.openProviderCondModal = () => {
        providerCondModal.classList.add('active');
        fetchProviders();
    };

    window.closeProviderCondModal = () => {
        providerCondModal.classList.remove('active');
    };

    window.closeEditProviderModal = () => {
        editProviderCondModal.classList.remove('active');
        editProvForm.reset();
    };

    const fetchProviders = async () => {
        providersTableBody.innerHTML = `<tr><td colspan="8" class="loading-cell"><div class="loader"></div><p>Cargando proveedores...</p></td></tr>`;
        try {
            const res = await fetch('/api/procurement/providers');
            if (!res.ok) throw new Error("Error al obtener proveedores");
            const json = await res.json();
            providersData = json.data || [];
            renderProvidersTable();
        } catch (error) {
            console.error('Error fetching providers:', error);
            providersTableBody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--danger);">Error al cargar proveedores.</td></tr>`;
        }
    };

    const renderProvidersTable = () => {
        const searchTerm = (providerSearchInput.value || '').toLowerCase();
        const showOnlyActive = providerActivoCheck ? providerActivoCheck.checked : true;

        const filtered = providersData.filter(p => {
            const matchesSearch = p.CodProv.toLowerCase().includes(searchTerm) ||
                (p.Descrip && p.Descrip.toLowerCase().includes(searchTerm));
            const matchesActive = showOnlyActive ? p.activo === 1 : true;
            return matchesSearch && matchesActive;
        });

        if (filtered.length === 0) {
            providersTableBody.innerHTML = `<tr><td colspan="8" style="text-align: center;">No hay resultados.</td></tr>`;
            return;
        }

        providersTableBody.innerHTML = filtered.map(p => `
            <tr>
                <td>${p.CodProv}</td>
                <td>${p.Descrip}</td>
                <td>${p.BaseDiasCredito === 'EMISION' ? 'Emisión' : 'Recepción'}</td>
                <td>${p.DiasNoIndexacion}</td>
                <td>${p.DiasVencimiento}</td>
                <td>${p.Email || '-'}</td>
                <td>${p.ProntoPago1_Pct}% (${p.ProntoPago1_Dias}d)</td>
                <td>${p.ProntoPago2_Pct}% (${p.ProntoPago2_Dias}d)</td>
                <td>
                    <button class="btn-icon" title="Editar Condiciones" onclick="openEditProvider('${p.CodProv}')">
                        <i data-lucide="edit-3" size="18"></i>
                    </button>
                </td>
            </tr>
        `).join('');
        lucide.createIcons();
    };

    window.openEditProvider = (codProv) => {
        const p = providersData.find(x => x.CodProv === codProv);
        if (!p) return;

        document.getElementById('editProvTitle').textContent = `Editar: ${p.Descrip}`;
        document.getElementById('editProvCod').value = p.CodProv;
        document.getElementById('editProvBase').value = p.BaseDiasCredito;
        document.getElementById('editProvDiasNI').value = p.DiasNoIndexacion;
        document.getElementById('editProvDiasV').value = p.DiasVencimiento;
        document.getElementById('editProvPP1Pct').value = p.ProntoPago1_Pct;
        document.getElementById('editProvPP1Dias').value = p.ProntoPago1_Dias;
        document.getElementById('editProvPP2Pct').value = p.ProntoPago2_Pct;
        document.getElementById('editProvPP2Dias').value = p.ProntoPago2_Dias;
        document.getElementById('editProvEmail').value = p.Email || '';

        editProviderCondModal.classList.add('active');
    };

    if (editProvForm) {
        editProvForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const codProv = document.getElementById('editProvCod').value;
            const payload = {
                CodProv: codProv,
                BaseDiasCredito: document.getElementById('editProvBase').value,
                DiasNoIndexacion: parseInt(document.getElementById('editProvDiasNI').value) || 0,
                DiasVencimiento: parseInt(document.getElementById('editProvDiasV').value) || 0,
                ProntoPago1_Pct: parseFloat(document.getElementById('editProvPP1Pct').value) || 0,
                ProntoPago1_Dias: parseInt(document.getElementById('editProvPP1Dias').value) || 0,
                ProntoPago2_Pct: parseFloat(document.getElementById('editProvPP2Pct').value) || 0,
                ProntoPago2_Dias: parseInt(document.getElementById('editProvPP2Dias').value) || 0,
                Email: document.getElementById('editProvEmail').value || null
            };

            const btn = editProvForm.querySelector('button[type="submit"]');
            const originalText = btn.textContent;
            btn.textContent = 'Guardando...';
            btn.disabled = true;

            try {
                const res = await fetch(`/api/procurement/providers/${codProv}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                if (!res.ok) throw new Error('Error al guardar parametrización');
                closeEditProviderModal();
                fetchProviders(); // Refresh list
            } catch (error) {
                console.error(error);
                alert('Error al guardar condiciones.');
            } finally {
                btn.textContent = originalText;
                btn.disabled = false;
            }
        });
    }

    if (document.getElementById('openProvidersBtn')) {
        document.getElementById('openProvidersBtn').addEventListener('click', openProviderCondModal);
    }
    if (document.getElementById('refreshProvidersBtn')) {
        document.getElementById('refreshProvidersBtn').addEventListener('click', fetchProviders);
    }
    if (providerSearchInput) {
        providerSearchInput.addEventListener('input', renderProvidersTable);
    }
    // ----- Módulo de Abonos y Pagos -----
    const abonosModal = document.getElementById('abonosModal');
    const abonoForm = document.getElementById('abonoForm');

    // UI Elements
    const abMontoOrigBs = document.getElementById('abMontoOrigBs');
    const abMontoOrigUsd = document.getElementById('abMontoOrigUsd');
    const abFechaBase = document.getElementById('abFechaBase');
    const abFechaNI = document.getElementById('abFechaNI');
    const abFechaPP1 = document.getElementById('abFechaPP1');
    const abFechaV = document.getElementById('abFechaV');
    const abSaldoUsd = document.getElementById('abSaldoUsd');
    const abonosHistoryBody = document.getElementById('abonosHistoryBody');

    // Form Inputs
    const abCodProv = document.getElementById('abCodProv');
    const abNumeroD = document.getElementById('abNumeroD');
    const abFechaPago = document.getElementById('abFechaPago');
    const abMontoBs = document.getElementById('abMontoBs');
    const abTasa = document.getElementById('abTasa');
    const abMontoUsd = document.getElementById('abMontoUsd');
    const abAplicaIndex = document.getElementById('abAplicaIndex');
    const abReferencia = document.getElementById('abReferencia');
    const abTasaLoader = document.getElementById('abTasaLoader');

    let currentCxpStatus = null;

    window.openAbonosPanel = async (codProv, numeroD) => {
        abonosModal.classList.add('active');
        resetAbonoForm();

        abCodProv.value = codProv;
        abNumeroD.value = numeroD;

        // Use today's date by default for payment
        setupDateInput(abFechaPago);
        setDateValue(abFechaPago, new Date().toISOString().split('T')[0]);

        await fetchCxpStatus(codProv, numeroD);
        await updateExchangeRate(); // fetch rate for today's date
    };

    window.closeAbonosModal = () => {
        abonosModal.classList.remove('active');
        currentCxpStatus = null;
    };

    const resetAbonoForm = () => {
        abonoForm.reset();
        abMontoBs.value = '';
        abMontoUsd.value = '';
        abTasa.value = '';
        abAplicaIndex.checked = false;

        abMontoOrigBs.textContent = 'Cargando...';
        abMontoOrigUsd.textContent = '...';
        abFechaBase.textContent = '...';
        abFechaNI.textContent = '...';
        abFechaPP1.textContent = '...';
        abFechaV.textContent = '...';
        abSaldoUsd.textContent = '...';
        const abBI = document.getElementById('abBaseImponible');
        const abIVA = document.getElementById('abIVA');
        const abEx = document.getElementById('abExento');
        if (abBI) abBI.textContent = '...';
        if (abIVA) abIVA.textContent = '...';
        if (abEx) abEx.textContent = '...';
        abonosHistoryBody.innerHTML = `<tr><td colspan="7" class="loading-cell"><div class="loader"></div></td></tr>`;

        const abTasaBadge = document.getElementById('abTasaBadge');
        if (abTasaBadge) abTasaBadge.textContent = 'Tasa: —';
    };

    const fetchCxpStatus = async (codProv, numeroD) => {
        try {
            const res = await fetch(`/api/procurement/cxp-status?cod_prov=${encodeURIComponent(codProv)}&numero_d=${encodeURIComponent(numeroD)}`);
            if (!res.ok) throw new Error("Factura no encontrada");
            const json = await res.json();
            currentCxpStatus = json.data;
            renderCxpStatus();
        } catch (error) {
            console.error('Error fetching cxp status:', error);
            alert('Error al cargar datos de la factura.');
            closeAbonosModal();
        }
    };

    const renderCxpStatus = () => {
        if (!currentCxpStatus) return;
        const d = currentCxpStatus;

        document.getElementById('abonoModalSubtitle').textContent = `Factura: ${d.NumeroD} | Proveedor: ${d.ProveedorNombre || d.CodProv}`;

        abMontoOrigBs.textContent = formatBs(d.Monto);
        abMontoOrigUsd.textContent = usdFormatter(d.MontoOriginalUSD);

        // Fiscal breakdown: Base Imponible, IVA, Exento
        const tGravable = d.TGravable || 0;
        const mtoTax = d.MtoTax || 0;
        const exento = Math.max(0, (d.Monto || 0) - tGravable - mtoTax);
        const abBIel = document.getElementById('abBaseImponible');
        const abIVAel = document.getElementById('abIVA');
        const abExel = document.getElementById('abExento');
        if (abBIel) abBIel.textContent = formatBs(tGravable);
        if (abIVAel) abIVAel.textContent = formatBs(mtoTax);
        if (abExel) abExel.textContent = formatBs(exento);

        const baseDate = d.BaseDiasCredito === 'EMISION' ? d.FechaE : (d.FechaI || d.FechaE);
        abFechaBase.textContent = formatDate(baseDate);
        abFechaNI.textContent = formatDate(d.FechaNI_Calculada);
        abFechaPP1.textContent = formatDate(d.FechaPP1);
        abFechaV.textContent = formatDate(d.FechaV_Calculada);

        abSaldoUsd.textContent = usdFormatter(d.SaldoRestanteUSD);

        // Update historical UP data
        document.getElementById('abNumeroUP').textContent = d.NumeroUP || '-';
        document.getElementById('abFechaUP').textContent = d.FechaUP ? formatDate(d.FechaUP) : '-';
        document.getElementById('abMontoUP').textContent = d.MontoUP != null ? formatBs(d.MontoUP) : '-';

        // Render History
        if (d.HistorialAbonos && d.HistorialAbonos.length > 0) {
            const tipoBadge = (tipo) => {
                const map = {
                    'PAGO': '<span class="status-badge status-paid">Pago</span>',
                    'RETENCION_IVA': '<span class="status-badge" style="background:rgba(139,92,246,0.15);color:#a78bfa;">Ret. IVA</span>',
                    'NOTA_CREDITO': '<span class="status-badge" style="background:rgba(59,130,246,0.15);color:#60a5fa;">N/C</span>'
                };
                return map[tipo] || `<span class="status-badge">${tipo || 'Pago'}</span>`;
            };
            abonosHistoryBody.innerHTML = d.HistorialAbonos.map(a => `
                <tr>
                    <td>${formatDate(a.FechaAbono)}</td>
                    <td>${tipoBadge(a.TipoAbono)}</td>
                    <td class="amount">${formatBs(a.MontoBsAbonado)}</td>
                    <td>${bsFormatter(a.TasaCambioDiaAbono)}</td>
                    <td>${a.AplicaIndexacion ? '<span class="status-badge status-overdue">Sí</span>' : '<span class="status-badge status-paid">No</span>'}</td>
                    <td class="amount us-amount">${usdFormatter(a.MontoUsdAbonado)}</td>
                    <td>${a.Referencia || '-'}</td>
                </tr>
            `).join('');
        } else {
            abonosHistoryBody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-secondary);">No hay abonos registrados.</td></tr>`;
        }

        // Show tasa for the invoice's BASE DATE (Emisión or Entrega) in the badge
        const baseDateStr = d.BaseDiasCredito === 'EMISION'
            ? (d.FechaE || '').split('T')[0]
            : ((d.FechaI || d.FechaE || '').split('T')[0]);
        const baseDateLabel = d.BaseDiasCredito === 'EMISION' ? 'Tasa Emis.' : 'Tasa Entr.';
        const abTasaBadge = document.getElementById('abTasaBadge');
        if (abTasaBadge && baseDateStr) {
            abTasaBadge.textContent = `${baseDateLabel}: ...`;
            fetch(`/api/exchange-rate?fecha=${encodeURIComponent(baseDateStr)}`)
                .then(r => r.ok ? r.json() : null)
                .then(json => {
                    if (json && json.rate) {
                        abTasaBadge.textContent = `${baseDateLabel}: ${json.rate.toFixed(2)}`;
                        abTasaBadge.style.color = 'var(--primary-accent)';
                        abTasaBadge.style.borderColor = 'rgba(99,102,241,0.4)';
                        abTasaBadge.title = `Tasa BCV del d\u00eda de ${d.BaseDiasCredito === 'EMISION' ? 'Emisi\u00f3n' : 'Entrega'} (${formatDate(baseDateStr)})`;
                    } else {
                        abTasaBadge.textContent = `${baseDateLabel}: N/D`;
                        abTasaBadge.style.color = 'var(--text-secondary)';
                    }
                })
                .catch(() => { abTasaBadge.textContent = `${baseDateLabel}: N/D`; });
        }

        // Auto-check indexation based on FechaPago vs FechaNI
        checkIndexationStatus();
    };

    const updateExchangeRate = async () => {
        const fecha = getDateValue(abFechaPago);
        if (!fecha) {
            abTasa.value = '';
            calculateUsdAmount();
            return;
        }

        abTasaLoader.style.display = 'block';
        try {
            const res = await fetch(`/api/exchange-rate?fecha=${encodeURIComponent(fecha)}`);
            if (res.ok) {
                const json = await res.json();
                abTasa.value = json.rate ? json.rate.toFixed(4) : '';

                checkIndexationStatus();
                fillDefaultPaymentAmount();
                calculateUsdAmount();
            }
        } catch (error) {
            console.error('Error fetching rate:', error);
        } finally {
            abTasaLoader.style.display = 'none';
        }
    };

    const checkIndexationStatus = () => {
        if (!currentCxpStatus || !getDateValue(abFechaPago)) return;
        const pagoDate = new Date(getDateValue(abFechaPago));
        const niDate = new Date(currentCxpStatus.FechaNI_Calculada);

        // Remove time portion for accurate day comparison
        pagoDate.setHours(0, 0, 0, 0);
        niDate.setHours(0, 0, 0, 0);

        // If payment date is STRICTLY greater than NI date, Indexation applies by default
        abAplicaIndex.checked = pagoDate > niDate;
        calculateUsdAmount();
    };

    const fillDefaultPaymentAmount = () => {
        if (!currentCxpStatus) return;

        if (abAplicaIndex.checked) {
            const rate = parseFloat(abTasa.value) || 0;
            if (rate > 0 && currentCxpStatus.SaldoRestanteUSD > 0) {
                // Indexado: Completar Saldo en USD al cambio actual
                abMontoBs.value = (currentCxpStatus.SaldoRestanteUSD * rate).toFixed(2);
            }
        } else {
            // No indexado: Completar Saldo original en Bs que quede en Saint
            if (currentCxpStatus.Saldo !== undefined && currentCxpStatus.Saldo !== null) {
                abMontoBs.value = currentCxpStatus.Saldo.toFixed(2);
            }
        }
    };

    const calculateUsdAmount = () => {
        const bs = parseFloat(abMontoBs.value) || 0;
        if (bs <= 0) {
            abMontoUsd.value = '';
            return;
        }

        if (!abAplicaIndex.checked && currentCxpStatus && currentCxpStatus.TasaEmision) {
            // Usa tasa original
            abMontoUsd.value = (bs / currentCxpStatus.TasaEmision).toFixed(2);
        } else {
            // Usa tasa del día
            const rate = parseFloat(abTasa.value) || 1;
            abMontoUsd.value = rate > 0 ? (bs / rate).toFixed(2) : '';
        }
    };

    // Event Listeners for Abono Form
    abFechaPago?.addEventListener('change', updateExchangeRate);
    abMontoBs?.addEventListener('input', calculateUsdAmount);
    abAplicaIndex?.addEventListener('change', () => {
        fillDefaultPaymentAmount();
        calculateUsdAmount();
    });

    abonoForm?.addEventListener('submit', async (e) => {
        e.preventDefault();
        if (!currentCxpStatus) return;

        const formData = new FormData();
        formData.append('NumeroD', abNumeroD.value);
        formData.append('CodProv', abCodProv.value);
        formData.append('FechaAbono', getDateValue(abFechaPago));
        formData.append('MontoBsAbonado', parseFloat(abMontoBs.value));
        formData.append('TasaCambioDiaAbono', abAplicaIndex.checked ? (parseFloat(abTasa.value) || 0) : (currentCxpStatus.TasaEmision || 0));
        formData.append('MontoUsdAbonado', parseFloat(abMontoUsd.value));
        formData.append('AplicaIndexacion', abAplicaIndex.checked);
        formData.append('Referencia', abReferencia.value);
        
        const notificar = document.getElementById('abNotificarCorreo')?.checked || false;
        formData.append('NotificarCorreo', notificar);

        const fileInput = document.getElementById('abComprobante');
        if (fileInput && fileInput.files.length > 0) {
            formData.append('archivo', fileInput.files[0]);
        }

        const btn = abonoForm.querySelector('button[type="submit"]');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<div class="loader" style="width: 16px; height: 16px; border-width: 2px;"></div> Procesando...';
        btn.disabled = true;

        try {
            const res = await fetch('/api/procurement/abonos', {
                method: 'POST',
                body: formData
            });

            if (!res.ok) throw new Error('Error al procesar pago');

            const resJson = await res.json();
            // Toast if email could not be sent (offline or no email)
            if (notificar && resJson.email_sent === false) {
                showToast('⚠️ Pago registrado. No se pudo enviar el correo (sin conexión o sin email del proveedor).', 'warning');
            } else if (notificar && resJson.email_sent !== false) {
                showToast('✅ Pago registrado y correo enviado exitosamente.', 'success');
            } else {
                showToast('✅ Abono registrado exitosamente.', 'success');
            }

            // Reload status to reflect new history and balance
            await fetchCxpStatus(abCodProv.value, abNumeroD.value);
            abMontoBs.value = '';
            abReferencia.value = '';
            calculateUsdAmount();

            if (typeof fetchData === 'function') fetchData();

        } catch (error) {
            console.error(error);
            alert('Error al registrar el abono.');
        } finally {
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    });

    // --- Re-enviar correo para facturas ya pagadas ---
    const btnResendEmail = document.getElementById('btnResendEmail');
    const abNotificarCorreo = document.getElementById('abNotificarCorreo');

    abNotificarCorreo?.addEventListener('change', () => {
        if (btnResendEmail) btnResendEmail.disabled = !abNotificarCorreo.checked;
    });

    btnResendEmail?.addEventListener('click', async () => {
        if (!currentCxpStatus) return;
        btnResendEmail.disabled = true;
        btnResendEmail.innerHTML = '<div class="loader" style="width:14px;height:14px;border-width:2px;"></div> Enviando...';
        try {
            const fd = new FormData();
            fd.append('NumeroD', abNumeroD.value);
            fd.append('CodProv', abCodProv.value);
            const fileInput = document.getElementById('abComprobante');
            if (fileInput && fileInput.files.length > 0) fd.append('archivo', fileInput.files[0]);
            const res = await fetch('/api/procurement/send-email', { method: 'POST', body: fd });
            const json = await res.json();
            if (json.email_sent !== false) {
                showToast('✅ Correo re-enviado exitosamente.', 'success');
            } else {
                showToast(`⚠️ ${json.message || 'No se pudo enviar el correo.'}`, 'warning');
            }
        } catch (err) {
            console.error(err);
            showToast('❌ Error al intentar re-enviar el correo.', 'error');
        } finally {
            btnResendEmail.disabled = false;
            btnResendEmail.innerHTML = '<i data-lucide="send"></i> Re-enviar correo';
            lucide.createIcons();
        }
    });
    // --------------------------------------------------

    // Carga Inicial
    setTimeout(() => {
        if (meshp && aniohp) fetchSavedBatch();
    }, 500);

    // Init Table Sorts
    window.setupSortableTable('cxpTable', 'currentData', 'renderTable', 'sortable', 'FechaE');
    window.setupSortableTable('expenseTemplatesTable', 'expenseTemplatesData', 'renderExpenseTemplates', 'sortable', 'descripcion');
    window.setupSortableTable('expenseBatchTableFijos', 'currentBatchData', 'renderBatchTable', 'sortable', 'descripcion');
    window.setupSortableTable('expenseBatchTableAdhoc', 'currentBatchData', 'renderBatchTable', 'sortable', 'descripcion');
    window.setupSortableTable('expenseSavedBatchTable', 'expenseSavedBatchData', 'renderSavedBatchTable', 'sortable', 'fecha_proyectada');

    // Listeners
    document.getElementById('expenseSavedBatchSearch')?.addEventListener('input', renderSavedBatchTable);

    // Provider list listeners
    providerSearchInput?.addEventListener('input', renderProvidersTable);
    providerActivoCheck?.addEventListener('change', renderProvidersTable);
    document.getElementById('refreshProvidersBtn')?.addEventListener('click', fetchProviders);

    // Initialize date inputs for DD/MM/YYYY display
    [
        filterDate, filterDateHasta, cashflowDateDesde, cashflowDateHasta,
        paramFechaCero, fcDateDesde, fcDateHasta, fsDateDesde, fsDateHasta,
        document.getElementById('eventFecha'),
        document.getElementById('planFecha'),
        document.getElementById('comprasDesde'),
        document.getElementById('comprasHasta')
    ].forEach(el => setupDateInput(el));

    loadCashflowParams();

    // --- Toast Utility ---
    window.showToast = (message, type = 'success') => {
        let container = document.getElementById('toastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toastContainer';
            container.style.cssText = 'position:fixed;bottom:1.5rem;right:1.5rem;display:flex;flex-direction:column;gap:0.5rem;z-index:99999;';
            document.body.appendChild(container);
        }
        const colors = { success: '#22c55e', warning: '#f59e0b', error: '#ef4444' };
        const toast = document.createElement('div');
        toast.style.cssText = `background:var(--bg-card);border:1px solid ${colors[type]||colors.success};color:var(--text-primary);padding:0.75rem 1.2rem;border-radius:8px;font-size:0.9rem;box-shadow:0 4px 20px rgba(0,0,0,0.4);max-width:360px;word-wrap:break-word;`;
        toast.textContent = message;
        container.appendChild(toast);
        setTimeout(() => { toast.remove(); }, 4500);
    };

    // --- Invoice Edit Modal ---
    const invoiceEditModal = document.getElementById('invoiceEditModal');
    const invoiceEditForm = document.getElementById('invoiceEditForm');

    window.closeInvoiceEditModal = () => {
        invoiceEditModal?.classList.remove('active');
    };

    document.getElementById('editInvoiceBtn')?.addEventListener('click', () => {
        const checked = document.querySelectorAll('.row-checkbox:checked');
        if (checked.length !== 1) return;
        const nroUnico = parseInt(checked[0].getAttribute('data-nrounico'));
        const item = window.currentData.find(d => d.NroUnico === nroUnico);
        if (!item) return;

        document.getElementById('ieNumeroD').value = item.NumeroD || '';
        document.getElementById('ieCodProv').value = item.CodProv || '';
        document.getElementById('ieFechaE').value = (item.FechaE || '').split('T')[0];
        document.getElementById('ieFechaI').value = (item.FechaI || '').split('T')[0];
        document.getElementById('ieFechaV').value = (item.FechaV || '').split('T')[0];
        document.getElementById('ieSaldoAct').value = item.Saldo || 0;
        // Notas10: '1' means indexed, anything else means not
        const n10 = item.Notas10;
        document.getElementById('ieNotas10').value = (n10 !== null && n10 !== undefined && String(n10).trim() === '1') ? '1' : '';
        document.getElementById('ieMontoFacturaBS').value = item.Monto || 0;
        document.getElementById('ieTGravable').value = item.TGravable || 0;
        document.getElementById('invoiceEditSubtitle').textContent = `Factura: ${item.NumeroD} | ${item.Descrip || ''}`;
        
        // Save cod_prov in the form for the PATCH request
        invoiceEditForm.dataset.codProv = item.CodProv || '';

        invoiceEditModal?.classList.add('active');
        lucide.createIcons();
    });

    invoiceEditForm?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const numeroD = document.getElementById('ieNumeroD').value;
        const codProv = document.getElementById('ieCodProv').value;
        if (!numeroD) return;

        const notas10Val = document.getElementById('ieNotas10')?.value;
        const payload = {
            FechaE: document.getElementById('ieFechaE').value || null,
            FechaI: document.getElementById('ieFechaI').value || null,
            FechaV: document.getElementById('ieFechaV').value || null,
            SaldoAct: parseFloat(document.getElementById('ieSaldoAct').value) || 0,
            Notas10: document.getElementById('ieNotas10').value || "",
            MontoFacturaBS: parseFloat(document.getElementById('ieMontoFacturaBS').value) || 0,
            TGravable: parseFloat(document.getElementById('ieTGravable').value) || 0,
            CodProv: invoiceEditForm.dataset.codProv || ""
        };
        // Only include Notas10 if user explicitly chose a value
        if (notas10Val !== '' && notas10Val !== undefined && notas10Val !== null) {
            payload.Notas10 = notas10Val;
        }

        const saveBtn = invoiceEditForm.querySelector('button[type="submit"]');
        const origText = saveBtn.innerHTML;
        saveBtn.innerHTML = '<div class="loader" style="width:14px;height:14px;border-width:2px;"></div> Guardando...';
        saveBtn.disabled = true;

        try {
            const res = await fetch(`/api/cuentas-por-pagar/${encodeURIComponent(numeroD)}?cod_prov=${encodeURIComponent(codProv)}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            if (!res.ok) throw new Error('Error al guardar cambios');
            showToast('✅ Factura actualizada correctamente.', 'success');
            window.closeInvoiceEditModal();
            await fetchData();
        } catch (err) {
            console.error(err);
            showToast('❌ Error al guardar cambios en la factura.', 'error');
        } finally {
            saveBtn.innerHTML = origText;
            saveBtn.disabled = false;
            lucide.createIcons();
        }
    });

    // ==========================================
    // PAGO MÚLTIPLE MODULE
    // ==========================================
    {
        const pmModal = document.getElementById('pagoMultipleModal');
        const pmForm = document.getElementById('pagoMultipleForm');
        let pmItems = []; // selected invoice data items
        let pmCxpStatuses = {}; // keyed by NumeroD

        window.closePagoMultipleModal = () => pmModal?.classList.remove('active');

        const pmRecalcTotals = () => {
            let totalBs = 0, totalUsd = 0, totalSaldo = 0;
            document.querySelectorAll('#pmInvoicesTable tr').forEach(row => {
                const bs = parseFloat(row.querySelector('.pm-monto-bs')?.value) || 0;
                const usd = parseFloat(row.querySelector('.pm-usd')?.textContent) || 0;
                const saldo = parseFloat(row.querySelector('.pm-saldo')?.textContent) || 0;
                totalBs += bs;
                totalUsd += usd;
                totalSaldo += saldo;
            });
            document.getElementById('pmTotalMontoBs').textContent = totalBs.toFixed(2);
            document.getElementById('pmTotalMontoUsd').textContent = totalUsd.toFixed(2);
            document.getElementById('pmTotalSaldoUsd').textContent = totalSaldo.toFixed(2);

            // Excess calc
            const montoReal = parseFloat(document.getElementById('pmMontoTotalReal')?.value) || 0;
            const diff = montoReal - totalBs;
            const group = document.getElementById('pmExcedenteGroup');
            if (diff > 0.01) {
                group.style.display = 'block';
                document.getElementById('pmExcedenteVal').textContent = `Bs.S ${bsFormatter(diff)}`;
            } else {
                group.style.display = 'none';
            }
        };

        document.getElementById('pmMontoTotalReal')?.addEventListener('input', pmRecalcTotals);

        const pmCalcRowUsd = (row) => {
            const bs = parseFloat(row.querySelector('.pm-monto-bs')?.value) || 0;
            const indexado = row.querySelector('.pm-indexado')?.checked;
            const tasa = parseFloat(row.querySelector('.pm-tasa')?.value) || 1;
            const nD = row.dataset.numerod;
            const cxp = pmCxpStatuses[nD];
            let usd = 0;

            if (!indexado && cxp && cxp.TasaEmision) {
                usd = bs / cxp.TasaEmision;
            } else {
                usd = tasa > 0 ? bs / tasa : 0;
            }

            row.querySelector('.pm-usd').textContent = usd.toFixed(2);
            pmRecalcTotals();
        };

        const pmFetchRate = async (row) => {
            const fechaInput = row.querySelector('.pm-fecha');
            const fecha = fechaInput?.value;
            if (!fecha) return;

            try {
                const res = await fetch(`/api/exchange-rate?fecha=${encodeURIComponent(fecha)}`);
                if (res.ok) {
                    const json = await res.json();
                    const tasaInput = row.querySelector('.pm-tasa');
                    tasaInput.value = json.rate ? json.rate.toFixed(4) : '';

                    // Auto-check indexation
                    const nD = row.dataset.numerod;
                    const cxp = pmCxpStatuses[nD];
                    if (cxp) {
                        const pagoDate = new Date(fecha);
                        const niDate = new Date(cxp.FechaNI_Calculada);
                        pagoDate.setHours(0,0,0,0);
                        niDate.setHours(0,0,0,0);
                        row.querySelector('.pm-indexado').checked = pagoDate > niDate;

                        // Fill default monto
                        const indexado = row.querySelector('.pm-indexado').checked;
                        const rate = parseFloat(tasaInput.value) || 0;
                        if (indexado && rate > 0 && cxp.SaldoRestanteUSD > 0) {
                            row.querySelector('.pm-monto-bs').value = (cxp.SaldoRestanteUSD * rate).toFixed(2);
                        } else if (!indexado && cxp.Saldo != null) {
                            row.querySelector('.pm-monto-bs').value = parseFloat(cxp.Saldo).toFixed(2);
                        }
                    }

                    pmCalcRowUsd(row);
                }
            } catch (e) { console.error(e); }
        };

        document.getElementById('btnPagoMultiple')?.addEventListener('click', async () => {
            const checked = document.querySelectorAll('.row-checkbox:checked');
            if (checked.length < 2) return;

            const items = [];
            checked.forEach(cb => {
                const nroUnico = parseInt(cb.getAttribute('data-nrounico'));
                const item = window.currentData.find(d => d.NroUnico === nroUnico);
                if (item) items.push(item);
            });
            if (items.length < 2) return;

            // Validate same provider
            const provs = new Set(items.map(i => i.CodProv));
            if (provs.size > 1) {
                showToast('⚠️ Para pago múltiple, todas las facturas deben ser del mismo proveedor.', 'warning');
                return;
            }

            pmItems = items;
            pmCxpStatuses = {};

            const provName = items[0].ProveedorNombre || items[0].CodProv;
            document.getElementById('pagoMultiSubtitle').textContent = `Proveedor: ${provName} | ${items.length} facturas seleccionadas`;

            const today = new Date().toISOString().split('T')[0];
            const tbody = document.getElementById('pmInvoicesTable');
            tbody.innerHTML = items.map(item => `
                <tr data-numerod="${item.NumeroD}" data-codprov="${item.CodProv}">
                    <td style="font-weight:500;">${item.NumeroD}</td>
                    <td class="amount pm-saldo" style="color:var(--success);">...</td>
                    <td><input type="date" class="form-control pm-fecha" value="${today}" style="width:130px;padding:0.3rem;font-size:0.8rem;"></td>
                    <td style="text-align:center;"><input type="checkbox" class="pm-indexado"></td>
                    <td><input type="number" class="form-control pm-tasa" step="0.0001" readonly style="width:75px;padding:0.3rem;font-size:0.8rem;background:var(--bg-card);"></td>
                    <td><input type="number" class="form-control pm-monto-bs" step="0.01" min="0.01" required style="width:110px;padding:0.3rem;font-size:0.8rem;"></td>
                    <td class="amount pm-usd" style="font-weight:bold;color:var(--success);">0.00</td>
                </tr>
            `).join('');

            // Attach event listeners
            tbody.querySelectorAll('tr').forEach(row => {
                row.querySelector('.pm-fecha')?.addEventListener('change', () => pmFetchRate(row));
                row.querySelector('.pm-monto-bs')?.addEventListener('input', () => pmCalcRowUsd(row));
                row.querySelector('.pm-indexado')?.addEventListener('change', () => {
                    const nD = row.dataset.numerod;
                    const cxp = pmCxpStatuses[nD];
                    const indexado = row.querySelector('.pm-indexado').checked;
                    const rate = parseFloat(row.querySelector('.pm-tasa').value) || 0;
                    if (cxp) {
                        if (indexado && rate > 0 && cxp.SaldoRestanteUSD > 0) {
                            row.querySelector('.pm-monto-bs').value = (cxp.SaldoRestanteUSD * rate).toFixed(2);
                        } else if (!indexado && cxp.Saldo != null) {
                            row.querySelector('.pm-monto-bs').value = parseFloat(cxp.Saldo).toFixed(2);
                        }
                    }
                    pmCalcRowUsd(row);
                });
            });

            pmModal.classList.add('active');
            lucide.createIcons();

            // Fetch CXP status and exchange rate for each invoice
            for (const item of items) {
                try {
                    const res = await fetch(`/api/procurement/cxp-status?cod_prov=${encodeURIComponent(item.CodProv)}&numero_d=${encodeURIComponent(item.NumeroD)}`);
                    if (res.ok) {
                        const json = await res.json();
                        pmCxpStatuses[item.NumeroD] = json.data;
                        const row = tbody.querySelector(`tr[data-numerod="${item.NumeroD}"]`);
                        if (row) {
                            row.querySelector('.pm-saldo').textContent = (json.data.SaldoRestanteUSD || 0).toFixed(2);
                            await pmFetchRate(row);
                        }
                    }
                } catch (e) { console.error(e); }
            }
            pmRecalcTotals();
        });

        pmForm?.addEventListener('submit', async (e) => {
            e.preventDefault();
            if (pmItems.length === 0) return;

            const btn = e.target.querySelector('button[type="submit"]');
            btn.innerHTML = '<div class="loader" style="width:16px;height:16px;border-width:2px;"></div> Procesando...';
            btn.disabled = true;

            const referencia = document.getElementById('pmReferencia').value;
            const notificar = document.getElementById('pmNotificarCorreo')?.checked || false;
            const fileInput = document.getElementById('pmComprobante');
            const rows = document.querySelectorAll('#pmInvoicesTable tr');

            // Build array of pagos
            const pagos = [];
            rows.forEach((row, idx) => {
                const nD = row.dataset.numerod;
                const codProv = row.dataset.codprov;
                const cxp = pmCxpStatuses[nD];
                const indexado = row.querySelector('.pm-indexado')?.checked;
                const tasa = parseFloat(row.querySelector('.pm-tasa')?.value) || 0;
                const montoBs = parseFloat(row.querySelector('.pm-monto-bs')?.value) || 0;
                const montoUsd = parseFloat(row.querySelector('.pm-usd')?.textContent) || 0;

                pagos.push({
                    NumeroD: nD,
                    CodProv: codProv,
                    FechaAbono: row.querySelector('.pm-fecha')?.value,
                    MontoBsAbonado: montoBs,
                    TasaCambioDiaAbono: indexado ? tasa : (cxp?.TasaEmision || 0),
                    MontoUsdAbonado: montoUsd,
                    AplicaIndexacion: indexado ? true : false,
                    Referencia: referencia
                });
            });

            // Use FormData to support file upload alongside JSON
            const formData = new FormData();
            formData.append('pagos_json', JSON.stringify(pagos));
            formData.append('NotificarCorreo', notificar);
            const montoReal = parseFloat(document.getElementById('pmMontoTotalReal')?.value) || 0;
            formData.append('MontoTotalPagado', montoReal);
            if (fileInput && fileInput.files.length > 0) {
                formData.append('archivo', fileInput.files[0]);
            }

            try {
                const res = await fetch('/api/procurement/abonos-batch', { method: 'POST', body: formData });
                if (!res.ok) {
                    const errBody = await res.json();
                    throw new Error(errBody.detail || 'Error al procesar pagos');
                }
                const result = await res.json();
                showToast(`✅ ${result.count || pagos.length} pagos registrados exitosamente.`, 'success');
                closePagoMultipleModal();
                if (typeof fetchData === 'function') fetchData();
            } catch (err) {
                console.error(err);
                showToast(`❌ ${err.message}`, 'error');
            }

            btn.innerHTML = '<i data-lucide="check-circle"></i> Procesar Pagos';
            btn.disabled = false;
            lucide.createIcons();
        });
    }

    // ==========================================
    // RETENCIONES IVA MODULE
    // ==========================================

    const retencionesView = document.getElementById('view-retenciones');
    if (retencionesView) {
        const fetchRetenciones = async () => {
            const tbody = document.getElementById('retencionesTableBody');
            if (!tbody) return;
            tbody.innerHTML = `<tr><td colspan="7" class="loading-cell"><div class="loader"></div><p>Cargando retenciones...</p></td></tr>`;

            try {
                let url = '/api/retenciones';
                const desde = getDateValue(document.getElementById('retencionesDesde'));
                const hasta = getDateValue(document.getElementById('retencionesHasta'));
                const params = new URLSearchParams();
                if (desde) params.append('desde', desde);
                if (hasta) params.append('hasta', hasta);
                if (params.toString()) url += '?' + params.toString();

                const res = await fetch(url);
                if (!res.ok) throw new Error('Error al cargar');
                const { data } = await res.json();

                if (!data || data.length === 0) {
                    tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-secondary);">No hay retenciones emitidas en el período.</td></tr>`;
                    return;
                }

                tbody.innerHTML = data.map(item => `
                    <tr>
                        <td><span style="font-weight: 500;">${item.NumeroComprobante}</span></td>
                        <td>${item.NumeroD || '-'}</td>
                        <td>${item.CodProv}</td>
                        <td>${formatDate(item.FechaRetencion)}</td>
                        <td class="amount">${formatBs(item.MontoTotal || 0)}</td>
                        <td class="amount" style="color: var(--warning); font-weight: 600;">${formatBs(item.MontoRetenido || 0)}</td>
                        <td style="text-align: center;">
                            <span class="badge ${item.Estado === 'EMITIDO' ? 'badge-warning' : (item.Estado === 'ENTERADO' ? 'badge-success' : 'badge-danger')}">${item.Estado}</span>
                        </td>
                        <td style="display:flex;gap:0.3rem;">
                            <button class="btn-icon" title="Ver PDF" onclick="window.open('/api/retenciones/${item.Id}/pdf', '_blank')" style="color:var(--primary-color);">
                                <i data-lucide="file-text"></i>
                            </button>
                            <button class="btn-icon" title="Enviar por Email" onclick="enviarRetencionEmail(${item.Id})" style="color:var(--success);">
                                <i data-lucide="send"></i>
                            </button>
                            ${item.Estado !== 'ANULADO' && item.Estado !== 'ENTERADO' ? `
                            <button class="btn-icon text-danger" title="Anular" onclick="anularRetencion(${item.Id})">
                                <i data-lucide="x-circle"></i>
                            </button>` : ''}
                        </td>
                    </tr>
                `).join('');
                lucide.createIcons();
            } catch (error) {
                console.error(error);
                tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--danger);">Error al cargar retenciones.</td></tr>`;
            }
        }; // end fetchRetenciones

        // Expose so the SPA router (switchView) can call it
        window._fetchRetenciones = fetchRetenciones;

        // Date Filters
        document.getElementById('retencionesDesde')?.addEventListener('change', fetchRetenciones);
        document.getElementById('retencionesHasta')?.addEventListener('change', fetchRetenciones);
        document.getElementById('refreshRetencionesBtn')?.addEventListener('click', fetchRetenciones);

        // Enviar Retención por Email
        window.enviarRetencionEmail = async (id) => {
            if (!confirm('¿Enviar comprobante de retención por correo al proveedor?')) return;
            showToast('Enviando correo...', 'info');
            try {
                const res = await fetch(`/api/retenciones/${id}/send-email`, { method: 'POST' });
                const json = await res.json();
                if (json.email_sent) {
                    showToast(`✅ ${json.message}`, 'success');
                } else {
                    showToast(`⚠️ ${json.message}`, 'warning');
                }
            } catch (e) {
                console.error(e);
                showToast('❌ Error al enviar correo de retención.', 'error');
            }
        };

        // Anular
        window.anularRetencion = async (id) => {
            if (!confirm('¿Seguro que desea anular esta retención de IVA? No se podrá revertir.')) return;
            try {
                const res = await fetch(`/api/retenciones/${id}`, {
                    method: 'PATCH',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ estatus: 'ANULADO' })
                });
                if (!res.ok) throw new Error('No se pudo anular');
                showToast('Retención anulada correctamente.', 'success');
                fetchRetenciones();
            } catch (e) {
                console.error(e);
                showToast('Error al anular la retención. Posiblemente ya está enterada al SENIAT.', 'error');
            }
        };

        // Text Export
        document.getElementById('exportRetencionesTxtBtn')?.addEventListener('click', async () => {
            if (!confirm('Esta acción exportará las retenciones EMITIDAS y las marcará como ENTERADAS (listas para declarar). ¿Desea continuar?')) return;
            try {
                const desde = getDateValue(document.getElementById('retencionesDesde'));
                const hasta = getDateValue(document.getElementById('retencionesHasta'));
                let url = '/api/retenciones/export-txt';
                const params = new URLSearchParams();
                if (desde) params.append('desde', desde);
                if (hasta) params.append('hasta', hasta);
                if (params.toString()) url += '?' + params.toString();

                window.location.href = url;
                setTimeout(fetchRetenciones, 2500); // refresh layout
            } catch (e) {
                console.error(e);
                showToast('Error en la exportación', 'error');
            }
        });

        // Config Modal
        const retConfigModal = document.getElementById('retConfigModal');
        const retConfigForm = document.getElementById('retConfigForm');

        document.getElementById('configRetencionesBtn')?.addEventListener('click', async () => {
            retConfigModal.classList.add('active');
            try {
                const res = await fetch('/api/retenciones/config');
                const { data } = await res.json();
                document.getElementById('cfgRifAgente').value = data.RifAgente || '';
                document.getElementById('cfgNombreAgente').value = data.NombreAgente || '';
                document.getElementById('cfgDireccionAgente').value = data.DireccionAgente || '';
                document.getElementById('cfgValorUT').value = data.ValorUT || 0;
                document.getElementById('cfgProximoSecuencial').value = data.ProximoSecuencial || 1;
            } catch (e) {
                console.error('Error fetching config', e);
            }
        });

        window.closeRetConfigModal = () => retConfigModal.classList.remove('active');

        retConfigForm?.addEventListener('submit', async (e) => {
            e.preventDefault();
            const btn = e.target.querySelector('button[type="submit"]');
            btn.innerHTML = '<i class="loader" style="width:14px;height:14px;"></i>';
            btn.disabled = true;

            const payload = {
                RifAgente: document.getElementById('cfgRifAgente').value,
                NombreAgente: document.getElementById('cfgNombreAgente').value,
                DireccionAgente: document.getElementById('cfgDireccionAgente').value,
                ValorUT: parseFloat(document.getElementById('cfgValorUT').value) || 0,
                ProximoSecuencial: parseInt(document.getElementById('cfgProximoSecuencial').value) || 1
            };

            try {
                const res = await fetch('/api/retenciones/config', {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                if (!res.ok) throw new Error('Error al guardar config');
                showToast('Configuración guardada exitosamente.', 'success');
                closeRetConfigModal();
            } catch (e) {
                console.error(e);
                showToast('Error al guardar.', 'error');
            } finally {
                btn.innerHTML = 'Guardar';
                btn.disabled = false;
            }
        });

        // Generar Retención (Multi-Factura)
        const generarRetencionModal = document.getElementById('generarRetencionModal');
        const generarRetencionForm = document.getElementById('generarRetencionForm');
        let currentRetencionItems = []; // Array of selected invoice items
        let configValUT = 0;

        const recalcAllRetenciones = () => {
            const retenPct = parseFloat(document.getElementById('genRetPctGaceta').value) || 0;
            let totalMonto = 0, totalBase = 0, totalIVA = 0, totalRetenido = 0;

            document.querySelectorAll('#genRetInvoicesTable tr').forEach((row, idx) => {
                const base = parseFloat(row.querySelector('.ret-base')?.value) || 0;
                const alicuota = parseFloat(row.querySelector('.ret-alicuota')?.value) || 0;
                const ivaCausado = base * (alicuota / 100);
                const retenido = ivaCausado * (retenPct / 100);
                const monto = parseFloat(row.querySelector('.ret-monto')?.textContent) || 0;

                row.querySelector('.ret-iva-display').textContent = ivaCausado.toFixed(2);
                row.querySelector('.ret-retenido-display').textContent = retenido.toFixed(2);

                totalMonto += monto;
                totalBase += base;
                totalIVA += ivaCausado;
                totalRetenido += retenido;
            });

            document.getElementById('genRetTotalMonto').textContent = totalMonto.toFixed(2);
            document.getElementById('genRetTotalBase').textContent = totalBase.toFixed(2);
            document.getElementById('genRetTotalIVA').textContent = totalIVA.toFixed(2);
            document.getElementById('genRetTotalRetenido').textContent = totalRetenido.toFixed(2);

            // UT Warning
            const warnBox = document.getElementById('retenWarningUT');
            if (configValUT > 0 && totalRetenido < (configValUT * 20)) {
                warnBox.style.display = 'block';
                warnBox.textContent = `Advertencia: El monto de retención (Bs. ${totalRetenido.toFixed(2)}) es menor a 20 Unidades Tributarias (Bs. ${(configValUT * 20).toFixed(2)}). Generalmente no se retiene.`;
            } else {
                warnBox.style.display = 'none';
            }
        };

        document.getElementById('btnGenerarRetencion')?.addEventListener('click', async () => {
            const checked = document.querySelectorAll('.row-checkbox:checked');
            if (checked.length < 1) return;

            // Gather all selected items
            const items = [];
            checked.forEach(cb => {
                const nroUnico = parseInt(cb.getAttribute('data-nrounico'));
                const item = window.currentData.find(d => d.NroUnico === nroUnico);
                if (item) items.push(item);
            });
            if (items.length === 0) return;

            // Validate: all same provider
            const provs = new Set(items.map(i => i.CodProv));
            if (provs.size > 1) {
                showToast('⚠️ Para generar una retención agrupada, todas las facturas deben ser del mismo proveedor.', 'warning');
                return;
            }

            // Fetch config for UT warning
            try {
                const resConf = await fetch('/api/retenciones/config');
                const confData = await resConf.json();
                configValUT = confData.data?.ValorUT || 0;
            } catch(e) {}

            currentRetencionItems = items;
            document.getElementById('genRetCodProv').value = items[0].CodProv;
            document.getElementById('genRetFechaEmision').value = new Date().toISOString().split('T')[0];
            document.getElementById('genRetPctGaceta').value = '75';

            // Build invoice rows
            const tbody = document.getElementById('genRetInvoicesTable');
            tbody.innerHTML = items.map((item, idx) => {
                const monto = parseFloat(item.Monto) || 0;
                const alicuota = 16;
                return `
                    <tr>
                        <td>${item.NumeroD}</td>
                        <td><input type="text" class="form-control ret-nrocontrol" value="${item.NroCtrol || ''}" style="width:100px;padding:0.3rem;font-size:0.8rem;"></td>
                        <td class="amount ret-monto">${monto.toFixed(2)}</td>
                        <td><input type="number" class="form-control ret-base" value="${monto.toFixed(2)}" step="0.01" style="width:90px;padding:0.3rem;font-size:0.8rem;"></td>
                        <td><input type="number" class="form-control ret-alicuota" value="${alicuota}" step="0.01" style="width:55px;padding:0.3rem;font-size:0.8rem;"></td>
                        <td class="amount ret-iva-display">${(monto * alicuota / 100).toFixed(2)}</td>
                        <td class="amount ret-retenido-display" style="font-weight:bold;color:var(--warning);">0.00</td>
                    </tr>
                `;
            }).join('');

            // Attach recalc listeners to editable inputs
            tbody.querySelectorAll('.ret-base, .ret-alicuota').forEach(inp => {
                inp.addEventListener('input', recalcAllRetenciones);
            });

            generarRetencionModal.classList.add('active');
            lucide.createIcons();
            recalcAllRetenciones();
        });

        document.getElementById('genRetPctGaceta')?.addEventListener('change', recalcAllRetenciones);

        window.closeGenerarRetencionModal = () => generarRetencionModal.classList.remove('active');

        generarRetencionForm?.addEventListener('submit', async (e) => {
            e.preventDefault();
            if (currentRetencionItems.length === 0) return;

            const btn = e.target.querySelector('button[type="submit"]');
            btn.innerHTML = '<i class="loader" style="width:14px;height:14px;"></i>';
            btn.disabled = true;

            const retenPct = parseFloat(document.getElementById('genRetPctGaceta').value) || 0;
            const fechaRetencion = document.getElementById('genRetFechaEmision').value;

            // Build facturas array from the table rows
            const rows = document.querySelectorAll('#genRetInvoicesTable tr');
            const facturas = [];
            rows.forEach((row, idx) => {
                const item = currentRetencionItems[idx];
                const base = parseFloat(row.querySelector('.ret-base')?.value) || 0;
                const alicuota = parseFloat(row.querySelector('.ret-alicuota')?.value) || 0;
                const ivaCausado = base * (alicuota / 100);
                const montoRetenido = ivaCausado * (retenPct / 100);
                const monto = parseFloat(row.querySelector('.ret-monto')?.textContent) || 0;
                const nroControl = row.querySelector('.ret-nrocontrol')?.value || '';

                facturas.push({
                    NumeroD: item.NumeroD,
                    CodProv: item.CodProv,
                    FechaFactura: item.FechaE || fechaRetencion,
                    NroControl: nroControl,
                    MontoTotal: monto,
                    BaseImponible: base,
                    MontoExento: Math.max(0, monto - base),
                    Alicuota: alicuota,
                    IVACausado: ivaCausado,
                    PorcentajeRetencion: retenPct,
                    MontoRetenido: montoRetenido
                });
            });

            try {
                const res = await fetch('/api/retenciones', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ FechaRetencion: fechaRetencion, facturas })
                });
                if (!res.ok) {
                    const errorJson = await res.json();
                    throw new Error(errorJson.detail || 'Error al generar retención');
                }
                const result = await res.json();
                showToast(`✅ Retención generada. Comprobante Nro: ${result.NumeroComprobante} (${facturas.length} factura${facturas.length > 1 ? 's' : ''})`, 'success');
                
                closeGenerarRetencionModal();
                if (typeof fetchData === 'function') fetchData();
            } catch (e) {
                console.error(e);
                showToast(e.message, 'error');
            } finally {
                btn.innerHTML = 'Generar Comprobante';
                btn.disabled = false;
            }
        });

        // Trigger fetchRetenciones when the view is opened via SPA routing link

        // Trigger fetchRetenciones when the view is opened via SPA routing link
        document.querySelector('.nav-item[data-view="retenciones"]')?.addEventListener('click', fetchRetenciones);
    }

    // --- Phase 5: Helper Functions for Direct Actions ---
    window.openRetencionFromMain = (codProv, numeroD) => {
        const item = window.currentData?.find(d => d.CodProv === codProv && d.NumeroD === numeroD);
        if (!item) return;
        document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
        const cb = document.querySelector(`.row-checkbox[data-nrounico="${item.NroUnico}"]`);
        if (cb) cb.checked = true;
        recalculateSelection();
        document.getElementById('btnGenerarRetencion')?.click();
    };

    window.openNCFromMain = (codProv, numeroD) => {
        openNewCreditNoteModal();
        setTimeout(() => {
            const codProvInput = document.getElementById('cncCodProv');
            const numDInput = document.getElementById('cncNumeroD');
            const montoBsInput = document.getElementById('cncMontoBs');
            const tasaInput = document.getElementById('cncTasa');
            const provider = window.allProviders?.find(p => p.CodProv === codProv);
            if (codProvInput) codProvInput.value = provider ? `${provider.CodProv} - ${provider.Descrip}` : codProv;
            if (numDInput) numDInput.value = numeroD;
            const item = window.currentData?.find(d => d.CodProv === codProv && d.NumeroD === numeroD);
            if (item) {
                if (montoBsInput) montoBsInput.value = (parseFloat(item.Saldo) || 0).toFixed(2);
                if (tasaInput) tasaInput.value = (parseFloat(item.TasaActual) || 0).toFixed(4);
            }
        }, 100);
    };

    window.openNDFromMain = (codProv, numeroD) => {
        const item = window.currentData?.find(d => d.CodProv === codProv && d.NumeroD === numeroD);
        if (!item) return;
        document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
        const cb = document.querySelector(`.row-checkbox[data-nrounico="${item.NroUnico}"]`);
        if (cb) cb.checked = true;
        recalculateSelection();
        showToast('Factura seleccionada. Use "Recibir N/D" en la vista de Notas de Débito.', 'info');
        switchView('debit-notes');
    };

    // --- Provider Datalist Logic ---
    window.allProviders = [];
    window.initProvidersDatalist = async () => {
        try {
            const res = await fetch('/api/procurement/providers');
            if (res.ok) {
                const json = await res.json();
                window.allProviders = json.data || [];
                const datalist = document.getElementById('datalistProviders');
                if (datalist) {
                    datalist.innerHTML = window.allProviders.map(p => 
                        `<option value="${p.CodProv} - ${p.Descrip}">`
                    ).join('');
                }
            }
        } catch (e) { console.error('Error in initProvidersDatalist:', e); }
    };

    initProvidersDatalist();

});

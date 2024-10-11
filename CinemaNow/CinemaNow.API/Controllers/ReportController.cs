using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("user-count")]
        public async Task<IActionResult> GetUserCount()
        {
            var userCount = await _reportService.GetUserCountAsync();
            return Ok(new { UserCount = userCount });
        }

        [HttpGet("total-income")]
        public async Task<IActionResult> GetTotalCinemaIncome()
        {
            var totalIncome = await _reportService.GetTotalCinemaIncomeAsync();
            return Ok(new { TotalIncome = totalIncome });
        }

    }
}

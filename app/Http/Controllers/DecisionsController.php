<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Services\Response;
use App\Repositories\DecisionRepository;
use App\Http\Traits\ValidatesRequestsCatcher;

class DecisionsController extends Controller
{
    use ValidatesRequestsCatcher;

    private $decisionRepository;
    private $response;

    public function __construct(Response $response, DecisionRepository $decision)
    {
        $this->decisionRepository = $decision;
        $this->response = $response;
    }

    public function index(Request $request)
    {
        return $this->response->jsonPaginator($this->decisionRepository->all($request->get('size')));
    }

    public function get($id)
    {
        return $this->response->json($this->decisionRepository->get($id));
    }

    public function create(Request $request)
    {
        $this->validate($request, ['table' => 'required|decisionStruct']);

        return $this->response->json(
            $this->decisionRepository->create($request->get('table')),
            Response::HTTP_CREATED
        );
    }

    public function update(Request $request, $id)
    {
        $this->validate($request, ['table' => 'required|decisionStruct']);

        return $this->response->json(
            $this->decisionRepository->update($id, $request->get('table'))
        );
    }

    public function delete($id)
    {
        return $this->response->json(
            $this->decisionRepository->delete($id)
        );
    }

    public function history(Request $request)
    {
        return $this->response->jsonPaginator(
            $this->decisionRepository->history($request->get('size'), $request->get('table_id'))
        );
    }

    public function historyItem($id)
    {
        return $this->response->json($this->decisionRepository->historyItem($id));
    }
}